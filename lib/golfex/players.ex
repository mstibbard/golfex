defmodule Golfex.Players do
  @moduledoc """
  The Players context."
  """
  alias Golfex.Repo
  alias Golfex.Players.Player
  alias Decimal, as: D
  alias Golfex.Scores

  def list_players() do
    players_ascending()
  end

  def get_player(id), do: Repo.get(Player, id)
  def get_player!(id), do: Repo.get(Player, id)

  def get_player_by(params), do: Repo.get_by(Player, params)

  def change_player(%Player{} = player), do: Player.changeset(player, %{})

  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  def players_ascending() do
    Player
    |> Player.players_alphabetically()
    |> Repo.all()
  end

  def list_active_players() do
    Player
    |> Player.active_players()
    |> Player.players_alphabetically()
    |> Repo.all()
  end

  def players_without_score_for_game_id(game_id) do
    base =
      Player
      |> Player.active_players()

    to_remove =
      base
      |> Player.existing_score(game_id)

    base
    |> Player.remove_existing(to_remove)
    |> Player.players_alphabetically_sub()
    |> Repo.all()
  end

  def get_division(min, max) do
    Player
    |> Player.active_players()
    |> Player.handicap_within_range(min, max)
    |> Repo.all()
    |> Enum.sort_by(& &1.name)
  end

  def get_attendance(year) do
    {:ok, min} = Date.new(year, 1, 1)
    {:ok, max} = Date.new(year, 12, 31)

    list_active_players()
    |> produce_attendance_map(min, max, [])
    |> Enum.sort_by(& &1.points, &>=/2)
  end

  def get_stableford(year) do
    {:ok, min} = Date.new(year, 1, 1)
    {:ok, max} = Date.new(year, 12, 31)

    list_active_players()
    |> produce_stableford_map(min, max, [])
    |> Enum.sort_by(& &1.stableford, &>=/2)
  end

  defp produce_attendance_map([], _min, _max, acc), do: acc

  defp produce_attendance_map([player | rest], min, max, acc) do
    vals = %{
      id: player.id,
      name: player.name,
      points: List.first(Scores.sum_player_scores_in_range!(player.id, min, max))
    }

    produce_attendance_map(rest, min, max, [vals | acc])
  end

  defp produce_stableford_map([], _min, _max, acc), do: acc

  defp produce_stableford_map([player | rest], min, max, acc) do
    result = Scores.get_stableford_top_scores(player.id, min, max)

    vals = %{
      id: player.id,
      name: player.name,
      stableford: result
    }

    produce_stableford_map(rest, min, max, [vals | acc])
  end
end
