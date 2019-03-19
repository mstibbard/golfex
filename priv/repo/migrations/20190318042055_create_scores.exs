defmodule Golfex.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :score, :integer
      add :handicap, :decimal
      add :handicap_change, :decimal
      add :new_handicap, :decimal
      add :points, :integer
      add :player_id, references(:players, on_delete: :nothing)
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end
  end
end
