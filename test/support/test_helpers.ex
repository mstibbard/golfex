defmodule Golfex.TestHelpers do
  alias Golfex.Accounts
  alias Golfex.Players
  alias Golfex.Games
  alias Golfex.Scores

  def user_fixture(attrs \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: username,
        credential: %{
          email: attrs[:email] || "#{username}@example.com",
          password: attrs[:password] || "supersecret"
        }
      })
      |> Accounts.register_user()

    user
  end

  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        name: "Namey McNameface",
        active: true,
        handicap: 10.0
      })
      |> Players.create_player()

    player
  end

  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        date: ~D[2019-03-04],
        type: "Stableford"
      })
      |> Games.create_game()

    game
  end

  def score_fixture(attrs \\ %{}) do
    {:ok, score} =
      attrs
      |> Enum.into(%{
        score: 36,
        handicap: 20.0,
        handicap_change: 0.0,
        new_handicap: 20.0,
        points: 1,
        player_id: 1,
        game_id: 1
      })
      |> Scores.create_score()

    score
  end
end
