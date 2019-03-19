defmodule Golfex.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :active, :boolean
      add :handicap, :decimal

      timestamps()
    end
  end
end
