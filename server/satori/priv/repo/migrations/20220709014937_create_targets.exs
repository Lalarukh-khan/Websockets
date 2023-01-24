defmodule Satori.Repo.Migrations.CreateTargets do
  use Ecto.Migration

  def change do
    create table(:targets) do
      add :name, :string

      timestamps()
    end
  end
end
