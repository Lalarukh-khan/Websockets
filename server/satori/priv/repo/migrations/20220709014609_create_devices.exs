defmodule Satori.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :cpu, :string
      add :disk, :integer
      add :bandwidth, :string
      add :ram, :integer
      add :wallet_id, :integer

      timestamps()
    end
  end
end
