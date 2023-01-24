defmodule Satori.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams) do
      add :wallet_id, :integer
      add :source_name, :string
      add :name, :string
      add :cadence, :string
      add :sanctioned, :boolean, default: false, null: false
      add :stream_id, :integer

      timestamps()
    end
  end
end
