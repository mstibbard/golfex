defmodule Golfex.ScoresTest do
  use Golfex.DataCase

  alias Golfex.Games.Score
  alias Golfex.Players
  alias Golfex.Scores
  alias Decimal, as: D

  describe "scores" do
    @valid_attrs %{
      score: 36,
      handicap: 0,
      handicap_change: 0.0,
      new_handicap: 0,
      points: 1,
      player_id: 0,
      game_id: 0
    }
    @update_attrs %{score: 40, handicap_change: 0.0, new_handicap: 0.0}
    @invalid_attrs %{
      score: -30,
      handicap_change: nil,
      player_id: nil,
      game_id: nil,
      new_handicap: nil
    }

    setup do
      %{id: game_id} = game_fixture()
      %{id: player_id, handicap: handicap} = player_fixture()

      {:ok, %{game_id: game_id, player_id: player_id, handicap: handicap}}
    end

    test "list_scores/0 lists all scores", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      assert Scores.list_scores() == [score]
    end

    test "get_score!/1 with valid id returns the score", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      assert Scores.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score", prep do
      attrs =
        prep
        |> Enum.into(@valid_attrs)

      assert {:ok, %Score{} = score} = Scores.create_score(attrs)
      assert score.score == 36
      assert score.handicap == D.new("10.0")
      assert score.handicap_change == D.new("0.3")
      assert score.new_handicap == D.new("10.3")

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("10.3")
    end

    test "create_score/1 with invalid data returns error changeset", prep do
      attrs =
        prep
        |> Enum.into(@invalid_attrs)

      assert {:error, %Ecto.Changeset{}} = Scores.create_score(attrs)
    end

    test "update_score/2 with valid data updates the score", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      prep = %{player_id: score.player_id, game_id: score.game_id}

      attrs =
        prep
        |> Enum.into(@update_attrs)

      assert {:ok, score} = Scores.update_score(score, attrs)
      assert %Score{} = score
      assert score.score == 40
      assert score.handicap_change == D.new("-1.0")
      assert score.new_handicap == D.new("9.0")

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("9.0")
    end

    test "update_score/2 with invalid data returns error changeset", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      assert {:error, %Ecto.Changeset{}} = Scores.update_score(score, @invalid_attrs)
      assert score == Scores.get_score!(score.id)
    end

    test "update_score/2 with handicap_change but no score updates correctly", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      attrs = %{points: 4, handicap_change: -3.0}

      assert {:ok, score} = Scores.update_score(score, attrs)
      assert %Score{} = score
      assert score.handicap == D.new("10.0")
      assert score.handicap_change == D.new("-3.0")
      assert score.new_handicap == D.new("7.0")

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("7.0")
    end

    test "delete_score/1 deletes the score and reverts handicap", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("10.3")

      assert {:ok, %Score{}} = Scores.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Scores.get_score!(score.id) end

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("10.0")
    end

    test "change_score/1 returns a score changeset", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      assert %Ecto.Changeset{} = Scores.change_score(score)
    end
  end
end
