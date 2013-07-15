Code.require_file "test_helper.exs", __DIR__

defmodule Poxa.EventHandlerTest do
  use ExUnit.Case
  alias Poxa.PusherEvent
  alias Poxa.Authentication
  import :meck
  import Poxa.EventHandler

  setup do
    new PusherEvent
    new Authentication
    new JSEX
    new :cowboy_req
  end

  teardown do
    unload PusherEvent
    unload Authentication
    unload JSEX
    unload :cowboy_req
  end

  test "init with a valid json" do
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(JSEX, :is_json?, 1, true)

    assert init(:transport, :req, :opts) == {:ok, :req1, :body}

    assert validate :cowboy_req
    assert validate JSEX
  end

  test "init with a invalid json" do
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(JSEX, :is_json?, 1, false)
    expect(:cowboy_req, :reply, 4,
                {:ok, :req2})

    assert init(:transport, :req, :opts) == {:shutdown, :req2, nil}

    assert validate :cowboy_req
    assert validate JSEX
  end

  test "single channel event" do
    expect(Authentication, :check, 4, :ok)
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1,
                [{"channel", "channel_name"},
                 {"name", "event_etc"} ])
    expect(:cowboy_req, :reply, 4, {:ok, :req4})
    expect(PusherEvent, :parse_channels, 1,
                {[{"name", "event_etc"}], :channels, nil})
    expect(PusherEvent, :valid?, 1, true)
    expect(PusherEvent, :send_message_to_channels, 3, :ok)

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate PusherEvent
    assert validate Authentication
    assert validate :cowboy_req
    assert validate JSEX
  end

  test "single channel event excluding socket_id" do
    expect(Authentication, :check, 4, :ok)
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})
    expect(PusherEvent, :parse_channels, 1,
                {[{"name", "event_etc"}], :channels, :exclude})
    expect(PusherEvent, :valid?, 1, true)
    expect(PusherEvent, :send_message_to_channels, 3, :ok)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate PusherEvent
    assert validate Authentication
    assert validate :cowboy_req
    assert validate JSEX
  end

  test "multiple channel event" do
    expect(Authentication, :check, 4, :ok)
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})
    expect(PusherEvent, :parse_channels, 1,
                {[{"name", "event_etc"}], :channels, nil})
    expect(PusherEvent, :send_message_to_channels, 3, :ok)
    expect(PusherEvent, :valid?, 1, true)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate PusherEvent
    assert validate Authentication
    assert validate :cowboy_req
    assert validate JSEX
  end

  test "invalid event" do
    expect(Authentication, :check, 4, :ok)
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})
    expect(PusherEvent, :valid?, 1, false)
    expect(PusherEvent, :parse_channels, 1,
                {[{"name", "event_etc"}], :channels, nil})

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate Authentication
    assert validate PusherEvent
    assert validate :cowboy_req
    assert validate JSEX
  end

  test "undefined channel event" do
    expect(Authentication, :check, 4, :ok)
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(PusherEvent, :valid?, 1, true)
    expect(PusherEvent, :parse_channels, 1,
                {[{"name", "event_etc"}], nil, nil})
    expect(:cowboy_req, :reply, 4, {:ok, :req4})

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate Authentication
    assert validate PusherEvent
    assert validate :cowboy_req
    assert validate JSEX
  end

  test "failing authentication" do
    expect(Authentication, :check, 4, :error)
    expect(:cowboy_req, :body, 1,
                {:ok, :body, :req1})
    expect(:cowboy_req, :qs_vals, 1, {:qsvals, :req2})
    expect(:cowboy_req, :method, 1, {:method, :req3})
    expect(:cowboy_req, :path, 1, {:path, :req3})
    expect(JSEX, :decode!, 1, :decoded_json)
    expect(:cowboy_req, :reply, 4, {:ok, :req4})

    assert handle(:req, :state) == {:ok, :req4, nil}

    assert validate Authentication
    assert validate PusherEvent
    assert validate :cowboy_req
    assert validate JSEX
  end
end
