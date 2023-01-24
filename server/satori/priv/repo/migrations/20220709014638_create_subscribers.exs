defmodule Satori.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :stream_id, :integer
      add :device_id, :integer
      add :target_id, :integer

      timestamps()
    end
  end
end
