defmodule SatoriWeb.GraphQL.Plugs.SetCurrentUser do
  # @behaviour Plug

  # import Plug.Conn
  # alias Satori.Accounts

  # def init(opts) do
  #   opts
  # end

  # def call(conn, _) do
  #   context = _build_context(conn)
  #   Absinthe.Plug.put_options(conn, context: context)
  # end

  # defp _build_context(conn) do
  #   with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
  #        {:ok, %{email: email}} <- SatoriWeb.GraphQL.AuthToken.verify(token),
  #        %{} = user <- Accounts.get_user_by_email(email) do
  #     %{current_user: user}
  #   else
  #     _ ->
  #       %{}
  #   end
  # end
end
