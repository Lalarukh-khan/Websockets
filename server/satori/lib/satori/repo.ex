defmodule Satori.Repo do
  use Ecto.Repo,
    otp_app: :satori,
    adapter: Ecto.Adapters.Postgres
end
