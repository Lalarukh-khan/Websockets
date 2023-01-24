defmodule SatoriWeb.GraphQL.AuthToken do
  @moduledoc """
  Working with GraphQL authentication tokens.
  """
  alias SatoriWeb.Endpoint
  alias Phoenix.Token

  def sign(user) do
    Token.sign(Endpoint, Application.get_env(:actiphy_portal, :graphql_salt), %{email: user.email})
  end

  def verify(token) do
    Token.verify(Endpoint, Application.get_env(:actiphy_portal, :graphql_salt), token,
      max_age: 365 * 24 * 3600
    )
  end
end
