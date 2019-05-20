defmodule Golfex.Repo.Migrations.AddRoundedHandicapToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
    	add :rounded_handicap, :integer
    end
  end
end
