defmodule Golfex.ScoresTest do
  use Golfex.DataCase

  alias Golfex.Games.Score
  alias Golfex.Players
  alias Golfex.Scores
  alias Decimal, as: D
  alias Golfex.Calculator, as: C

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

      expected = D.add("15.0", C.inc())
      assert {:ok, %Score{} = score} = Scores.create_score(attrs)
      assert score.score == 36
      assert score.handicap == D.new("15.0")
      assert score.handicap_change == C.inc()
      assert score.new_handicap == expected

      player = Players.get_player!(score.player_id)
      assert player.handicap == expected
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

      expected = D.add("15.00", C.dec2())
      assert {:ok, score} = Scores.update_score(score, attrs)
      assert %Score{} = score
      assert score.score == 40
      assert score.handicap_change == C.dec2()
      assert score.new_handicap == expected

      player = Players.get_player!(score.player_id)
      assert player.handicap == expected
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
      assert score.handicap == D.new("15.0")
      assert score.handicap_change == D.new("-3.0")
      assert score.new_handicap == D.new("12.0")

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("12.0")
    end

    test "update_score/2 does not exceed maximum handicap", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      attrs = %{handicap_change: 50.0}

      assert {:ok, score} = Scores.update_score(score, attrs)
      assert %Score{} = score
      assert score.handicap == D.new("15.0")
      assert score.handicap_change == D.new("30.00")
      assert score.new_handicap == D.new("45.00")
    end

    test "update_score/2 does not exceed minimum handicap", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      attrs = %{handicap_change: -30.0}

      assert {:ok, score} = Scores.update_score(score, attrs)
      assert %Score{} = score
      assert score.handicap == D.new("15.0")
      assert score.handicap_change == D.new("-5.00")
      assert score.new_handicap == D.new("10.00")
    end

    test "delete_score/1 deletes the score and reverts handicap", prep do
      score =
        score_fixture(%{
          game_id: prep.game_id,
          player_id: prep.player_id,
          handicap: prep.handicap
        })

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.add("15.00", C.inc())

      assert {:ok, %Score{}} = Scores.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Scores.get_score!(score.id) end

      player = Players.get_player!(score.player_id)
      assert player.handicap == D.new("15.00")
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

    test "create_score/1 with valid fun match data creates a score" do
      # Setting up unique game and player details for this test
      %{id: game_id} = game_fixture(%{type: "Fun"})
      %{id: player_id, handicap: handicap} = player_fixture(%{handicap: D.new("29.9")})
      
      attrs = %{
        score: 36,
        handicap: handicap,
        handicap_change: 0.0,
        new_handicap: 0,
        points: 1,
        player_id: player_id,
        game_id: game_id
      }

      assert {:ok, %Score{} = score} = Scores.create_score(attrs)
      assert score.score == 36
      assert score.handicap == handicap
      assert score.handicap_change == D.new("0.0")
      assert score.new_handicap == handicap

      player = Players.get_player!(score.player_id)
      assert player.handicap == handicap
    end
  end
end
