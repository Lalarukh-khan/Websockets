defmodule Satori.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      #add :user_id, :integer
      add :address, :string
      add :public_key, :string

      timestamps()
    end

    create(unique_index(:wallets, [:public_key]))

    create table(:wallets_tokens) do
      add(:wallet_id, references(:wallets, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)
      timestamps(updated_at: false)
    end

    create(index(:wallets_tokens, [:wallet_id]))
    create(unique_index(:wallets_tokens, [:context, :token]))
  end
end
