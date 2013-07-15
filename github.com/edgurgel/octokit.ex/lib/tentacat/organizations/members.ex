defmodule Tentacat.Organizations.Members do
  import Tentacat.Client.Base
  alias Tentacat.Client

  @doc """
  List members of a `organization`. The response will differ if the authenticated user is also owner of the organization

  ## Example

      Tentacat.Organizations.Members.list "github"
      Tentacat.Organizations.Members.list "github", client

  More info at: http://developer.github.com/v3/orgs/members/#members-list
  """
  @spec list(binary, Client.t) :: Base.response
  def list(organization, client // Client.new) do
    get "orgs/#{organization}/members", client.auth
  end

  @doc """
  Check if a `user` is, publicly or privately, a member of the `organization`.

  Possible responses: 204, 404 or 302

  ## Example

      Tentacat.Organizations.Members.member? "github", "mojombo"
      Tentacat.Organizations.Members.member? "github", "mojombo", client

  More info at: http://developer.github.com/v3/orgs/members/#check-membership
  """
  @spec member?(binary, binary, Client.t) :: Base.response
  def member?(organization, user, client // Client.new) do
    get "orgs/#{organization}/members/#{user}", client.auth
  end

  @doc """
  Remove a member `user` from an `organization`

  ## Example

      Tentacat.Organizations.Members.remove "github", "mojombo", client

  More info at: http://developer.github.com/v3/orgs/members/#remove-a-member
  """
  @spec remove(binary, binary, Client.t) :: Base.response
  def remove(organization, user, client) do
    delete "orgs/#{organization}/members/#{user}", client.auth
  end

  @doc """
  List of publicized members of an `organization`

  ## Example

      Tentacat.Organizations.Members.public_list "github"
      Tentacat.Organizations.Members.public_list "github", client

  More info at: http://developer.github.com/v3/orgs/members/#public-members-list
  """
  @spec public_list(binary, Client.t) :: Base.response
  def public_list(organization, client // Client.new) do
    get "orgs/#{organization}/public_members", client.auth
  end

  @doc """
  Check if a `user` is a public member of the `organization`.

  Possible responses: 204 or 404

  ## Example

      Tentacat.Organizations.Members.public_member? "github", "mojombo"
      Tentacat.Organizations.Members.public_member? "github", "mojombo", client

  More info at: http://developer.github.com/v3/orgs/members/#public-members-list
  """
  @spec public_member?(binary, binary, Client.t) :: Base.response
  def public_member?(organization, user, client // Client.new) do
    get "orgs/#{organization}/public_members/#{user}", client.auth
  end

  @doc """
  Publicize a `user`'s membership on an `organization`

  ## Example

      Tentacat.Organizations.Members.publicize "github", "mojombo"

  More info at: http://developer.github.com/v3/orgs/members/#publicize-a-users-membership
  """
  @spec publicize(binary, binary, Client.t) :: Base.response
  def publicize(organization, user, client) do
    put "orgs/#{organization}/public_members/#{user}", client.auth
  end

  @doc """
  Conceal a `user`'s membership on an `organization`

  ## Example

      Tentacat.Organizations.Members.conceal "github", "mojombo"

  More info at: http://developer.github.com/v3/orgs/members/#conceal-a-users-membership
  """
  @spec conceal(binary, binary, Client.t) :: Base.response
  def conceal(organization, user, client) do
    delete "orgs/#{organization}/public_members/#{user}", client.auth
  end

end
