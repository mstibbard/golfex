defmodule Golfex.Scores do
  @moduledoc """
  The Scores context.
  """

  import Ecto.Query, warn: false
  alias Golfex.Repo

  alias Ecto.Changeset
  alias Decimal, as: D
  alias Golfex.Calculator, as: C
  alias Golfex.Games
  alias Golfex.Games.Score
  alias Golfex.Players

  def list_scores do
    Score
    |> Repo.all()
  end

  def get_scores_by_game_id!(game_id) do
    Score
    |> Score.by_game_id(game_id)
    |> Repo.all()
  end

  def get_scores_by_player_id!(player_id) do
    Score
    |> Score.by_player_id(player_id)
    |> Repo.all()
  end

  def get_score!(id), do: Repo.get!(Score, id)

  def create_score(attrs \\ %{}) do
    %Score{}
    |> Score.changeset(attrs)
    |> populate_changeset()
    |> Repo.insert()
  end

  def update_score(%Score{} = score, attrs) do
    score
    |> Score.changeset(attrs)
    |> populate_changeset()
    |> Repo.update()
  end

  def update_many_scores(scores, game_attrs) do
    Enum.each(scores, fn x ->
      recalculate_handicap(x, game_attrs)
    end)
  end

  def delete_score(%Score{} = score) do
    Players.get_player!(score.player_id)
    |> revert_handicap(D.minus(score.handicap_change))

    Repo.delete(score)
  end

  def delete_many_scores(scores) do
    Enum.each(scores, fn x ->
      get_score!(x.id)
      |> delete_score()
    end)
  end

  def change_score(%Score{} = score), do: Score.changeset(score, %{})

  def sum_player_scores_in_range!(player_id, min, max) do
    Score
    |> Score.within_date_range(player_id, min, max)
    |> Repo.all()
  end

  def get_stableford_top_scores(player_id, min, max) do
    Score
    |> Score.stableford_within_date_range(player_id, min, max)
    |> Repo.all()
    |> Enum.slice(0..5)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
    # Below commented out to return to an aggregate of top 6 instead of average
    # |> D.div(6)
    # |> D.round(0, :half_up)
  end

  defp populate_changeset(changeset) do
    %{player: player, game: game} = get_player_and_game(changeset)

    score = Changeset.get_change(changeset, :score)

    changeset
    |> put_handicap(player.handicap)
    |> put_change(score, player.handicap, game.type)
    |> put_new_handicap(player.handicap)
    |> update_player_table(player)
  end

  defp put_handicap(changeset = %{data: %{handicap: hc}}, handicap) when hc == nil do
    Changeset.put_change(changeset, :handicap, handicap)
  end

  defp put_handicap(changeset, _handicap), do: changeset

  # Catches manually entered handicap changes that would cause
  # the new handicap to exceed the min/max limits
  defp put_change(changeset = %{data: %{handicap: hc}}, nil, _handicap, _type) when hc == nil do
    Changeset.put_change(
      changeset,
      :handicap_change,
      C.valid_change(changeset.changes.handicap_change, changeset.changes.handicap)
    )
  end

  defp put_change(changeset, nil, _handicap, _type) do
    if Map.has_key?(changeset.changes, :handicap_change) do
      Changeset.put_change(
        changeset,
        :handicap_change,
        C.valid_change(changeset.changes.handicap_change, changeset.data.handicap)
      )
    else
      changeset
    end
  end

  defp put_change(changeset, score, handicap, type) do
    Changeset.put_change(
      changeset,
      :handicap_change,
      C.calculate_change(score, type, handicap)
    )
  end

  defp put_new_handicap(changeset = %{changes: %{handicap_change: change}}, handicap) do
    new_handicap = D.add(handicap, change)

    cond do
      D.cmp(new_handicap, C.max()) == :gt ->
        Changeset.put_change(changeset, :new_handicap, C.max())

      D.cmp(new_handicap, C.min()) == :lt ->
        Changeset.put_change(changeset, :new_handicap, C.min())

      changeset.data.handicap_change >= D.new("0.0") ->
        Changeset.put_change(
          changeset,
          :new_handicap,
          D.add(changeset.data.handicap, change)
        )

      true ->
        Changeset.put_change(changeset, :new_handicap, new_handicap)
    end
  end

  defp put_new_handicap(changeset, _handicap) do
    changeset
  end

  defp get_player_and_game(changeset) do
    {_, player_id} = Changeset.fetch_field(changeset, :player_id)
    {_, game_id} = Changeset.fetch_field(changeset, :game_id)

    player = Players.get_player!(player_id)
    game = Games.get_game!(game_id)

    %{player: player, game: game}
  end

  defp update_player_table(changeset, player) do
    cond do
      Map.has_key?(changeset.changes, :new_handicap) ->
        Players.update_player(player, %{handicap: changeset.changes.new_handicap})
        changeset

      true ->
        changeset
    end
  end

  defp revert_handicap(player, change) do
    attrs = %{handicap: D.add(player.handicap, change)}
    Players.update_player(player, attrs)
  end

  defp recalculate_handicap(score, game_attrs) do
    cond do
      Map.has_key?(game_attrs, "type") ->
        %{"type" => type} = game_attrs
        player = Players.get_player!(score.player_id)

        score
        |> Score.changeset()
        |> put_change(score.score, score.handicap, type)
        |> put_new_handicap(score.handicap)
        |> update_player_table(player)
        |> Repo.update()

      true ->
        score
    end
  end
end
