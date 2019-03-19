defmodule Golfex.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "games" do
    field(:date, :date)
    field(:type, :string)

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:date, :type])
    |> validate_required([:date, :type])
  end

  def games_date_descending(query) do
    from(g in query, order_by: [desc: g.date])
  end
end
