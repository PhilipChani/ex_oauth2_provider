defmodule ExOauth2Provider.Config do
  @moduledoc false

  @config                        ExOauth2Provider.config

  @doc false
  @resource_owner_struct         Keyword.get(@config, :resource_owner)
  def resource_owner_struct,     do: @resource_owner_struct

  @doc false
  @application_resource_owner_struct     Keyword.get(@config, :application_resource_owner, @resource_owner_struct)
  def application_resource_owner_struct, do: @application_resource_owner_struct

  # Define default access token scopes for your provider
  @doc false
  @default_scopes                Keyword.get(@config, :default_scopes, [])
  def default_scopes,            do: @default_scopes

  # Define optional access token scopes for your provider
  @optional_scopes               Keyword.get(@config, :optional_scopes, [])

  # Combined scopes list for your provider
  @doc false
  @server_scopes                 @default_scopes ++ @optional_scopes
  def server_scopes,             do: @server_scopes

  @doc false
  @native_redirect_uri           Keyword.get(@config, :native_redirect_uri, "urn:ietf:wg:oauth:2.0:oob")
  def native_redirect_uri,       do: @native_redirect_uri

  @doc false
  @authorization_code_expires_in     Keyword.get(@config, :authorization_code_expires_in, 600)
  def authorization_code_expires_in, do: @authorization_code_expires_in

  @doc false
  @access_token_expires_in       Keyword.get(@config, :access_token_expires_in, 7200)
  def access_token_expires_in,   do: @access_token_expires_in

  # Issue access tokens with refresh token (disabled by default)
  @doc false
  @use_refresh_token             Keyword.get(@config, :use_refresh_token, false)
  def use_refresh_token?,        do: @use_refresh_token

  # Password auth method to use. Disabled by default. When set, it'll enable
  # password auth strategy. Set config as:
  # `password_auth: {MyModule, :my_auth_method}`
  @doc false
  @password_auth                 Keyword.get(@config, :password_auth, nil)
  def password_auth,             do: @password_auth

  @doc false
  @refresh_token_revoked_on_use      Keyword.get(@config, :revoke_refresh_token_on_use, false)
  def refresh_token_revoked_on_use?, do: @refresh_token_revoked_on_use

  # Forces the usage of the HTTPS protocol in non-native redirect uris
  # (enabled by default in non-development environments). OAuth2
  # delegates security in communication to the HTTPS protocol so it is
  # wise to keep this enabled.
  @doc false
  @force_ssl_in_redirect_uri      Keyword.get(@config, :force_ssl_in_redirect_uri, Mix.env != :dev)
  def force_ssl_in_redirect_uri?, do: @force_ssl_in_redirect_uri

  # Use a custom access token generator
  @doc false
  @access_token_generator         Keyword.get(@config, :access_token_generator, nil)
  def access_token_generator,     do: @access_token_generator

  @access_token_response_body_handler     Keyword.get(@config, :access_token_response_body_handler, nil)
  def access_token_response_body_handler, do: @access_token_response_body_handler

  @doc false
  @grant_flows                  Keyword.get(@config, :grant_flows, ~w(authorization_code client_credentials))
  def grant_flows,              do: @grant_flows

  @doc false
  def calculate_authorization_response_types do
    %{"authorization_code" => {:code, ExOauth2Provider.Authorization.Code}}
    |> Enum.filter(fn({k,_}) -> Enum.member?(grant_flows(), k) end)
    |> Enum.map(fn({_,v}) -> v end)
  end

  @doc false
  def calculate_token_grant_types do
    [authorization_code: ExOauth2Provider.Token.AuthorizationCode,
     client_credentials: ExOauth2Provider.Token.ClientCredentials,
     password: ExOauth2Provider.Token.Password,
     refresh_token: ExOauth2Provider.Token.RefreshToken]
    |> Enum.filter(fn({k,_}) -> grant_type_can_be_used?(grant_flows(), to_string(k)) end)
  end

  defp grant_type_can_be_used?(_, "refresh_token"),
    do: use_refresh_token?()
  defp grant_type_can_be_used?(_, "password"),
    do: not is_nil(password_auth())
  defp grant_type_can_be_used?(grant_flows, grant_type) do
    Enum.member?(grant_flows, grant_type)
  end
end