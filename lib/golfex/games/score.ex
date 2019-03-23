defmodule Golfex.Games.Score do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "scores" do
    field(:score, :integer)
    field(:handicap, :decimal)
    field(:handicap_change, :decimal)
    field(:new_handicap, :decimal)
    field(:points, :integer)

    belongs_to(:player, Golfex.Players.Player)
    belongs_to(:game, Golfex.Games.Game)

    timestamps()
  end

  @doc false
  def changeset(score, attrs \\ %{}) do
    score
    |> cast(attrs, [
      :score,
      :handicap,
      :handicap_change,
      :new_handicap,
      :player_id,
      :game_id,
      :points
    ])
    |> validate_required([
      :score,
      :handicap,
      :handicap_change,
      :new_handicap,
      :player_id,
      :game_id,
      :points
    ])
  end

  def by_game_id(query, game_id) do
    from(s in query,
      preload: [:player],
      where: s.game_id == ^game_id,
      join: p in assoc(s, :player),
      order_by: [asc: p.name]
    )
  end

  def by_player_id(query, player_id) do
    from(s in query,
      preload: [:game],
      where: s.player_id == ^player_id,
      join: g in assoc(s, :game),
      order_by: [desc: g.date]
    )
  end

  def within_date_range(query, player_id, min, max) do
    from(s in query,
      join: g in assoc(s, :game),
      where: s.player_id == ^player_id and g.date >= ^min and g.date <= ^max,
      select: sum(s.points)
    )
  end

  def stableford_within_date_range(query, player_id, min, max) do
    from(s in query,
      join: g in assoc(s, :game),
      where:
        s.player_id == ^player_id and g.date >= ^min and g.date <= ^max and g.type == "Stableford",
      select: s.score,
      order_by: [desc: s.score]
    )
  end
end
