defmodule Golfex.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "players" do
    field(:name, :string)
    field(:active, :boolean)
    field(:handicap, :decimal)

    has_many(:score, Golfex.Games.Score)

    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :active, :handicap])
    |> validate_required([:name, :active, :handicap])
  end

  def active_players(query) do
    from(p in query, where: p.active == true)
  end

  def players_alphabetically(query) do
    from(p in query, order_by: [asc: p.name])
  end

  def players_alphabetically_sub(query) do
    from(p in subquery(query), order_by: [asc: p.name])
  end

  def existing_score(query, game_id) do
    from(p in query,
      join: s in assoc(p, :score),
      where: s.game_id == ^game_id
    )
  end

  def remove_existing(query, to_remove) do
    from(p in query,
      select: p,
      except: ^to_remove
    )
  end

  def handicap_within_range(query, min, max) do
    from(p in query,
      where: p.handicap >= ^min and p.handicap <= ^max
    )
  end
end
