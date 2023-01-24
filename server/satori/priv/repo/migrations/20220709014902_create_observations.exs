defmodule Satori.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations) do
      add :stream_id, :integer
      add :wallet_id, :integer
      add :target_id, :integer
      add :value, :string

      timestamps()
    end
  end
end
