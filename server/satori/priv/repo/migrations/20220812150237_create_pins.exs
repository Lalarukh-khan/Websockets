defmodule Satori.Repo.Migrations.CreatePins do
  use Ecto.Migration

  def change do
    create table(:pins) do
      add :wallet_id, :integer
      add :stream_id, :integer
      add :target_id, :integer
      add :ipns, :string
      add :ipfs, :string

      timestamps()
    end
  end
end
