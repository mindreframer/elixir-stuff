defmodule Poxa.ChannelsHandler do
  @moduledoc """
  This module contains Cowboy HTTP handler callbacks to request on /apps/:app_id/channels[/:channel]

  More info on Pusher REST API at: http://pusher.com/docs/rest_api#channels
  """

  require Lager
  alias Poxa.AuthorizationHelper
  alias Poxa.PresenceSubscription
  alias Poxa.Subscription

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  @valid_attributes ["user_count", "subscription_count"]

  def malformed_request(req, _state) do
    {info, req} = :cowboy_req.qs_val("info", req, "")
    attributes = String.split(info, ",")
    {channel, req} = :cowboy_req.binding(:channel_name, req, nil)
    if channel do
      {malformed_request_one_channel?(attributes, channel), req, {channel, attributes}}
    else
      {false, req, nil}
    end
  end

  defp malformed_request_one_channel?(attributes, channel) do
    if Enum.all?(attributes, fn s -> Enum.member?(@valid_attributes, s) end) do
      !PresenceSubscription.presence_channel?(channel) and Enum.member?(attributes, "user_count")
    else
      true
    end
  end

  def is_authorized(req, state) do
    AuthorizationHelper.is_authorized(req, state)
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, {channel, attributes}) do
    if channel do
      show(channel, attributes, req, nil)
    else
      index(req, nil)
    end
  end

  defp show(channel, attributes, req, state) do
    occupied = Subscription.occupied?(channel)
    attribute_list = mount_attribute_list(attributes, channel)
    {JSEX.encode!([occupied: occupied] ++ attribute_list), req, state}
  end

  defp mount_attribute_list(attributes, channel) do
    attribute_list =
      if Enum.member?(attributes, "subscription_count") do
        [subscription_count: Subscription.subscription_count(channel)]
      else
        []
      end
    attribute_list ++
      if Enum.member?(attributes, "user_count") do
        [user_count: PresenceSubscription.user_count(channel)]
      else
        []
      end
  end

  defp index(req, state) do
    channels =
      Subscription.all_channels
        |> Enum.filter_map(
          fn channel ->
            PresenceSubscription.presence_channel? channel
          end,
          fn channel ->
            {channel, [user_count: PresenceSubscription.user_count(channel)]}
          end)
    {JSEX.encode!(channels: channels), req, state}
  end

end
