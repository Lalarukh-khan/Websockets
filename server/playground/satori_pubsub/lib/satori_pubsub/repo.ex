defmodule SatoriPubsub.Repo do
  use Ecto.Repo,
    otp_app: :satori_pubsub,
    adapter: Ecto.Adapters.Postgres
end
