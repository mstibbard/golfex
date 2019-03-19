defmodule GolfexWeb.ScoreControllerTest do
  use GolfexWeb.ConnCase

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.score_path(conn, :new, "1")),
        get(conn, Routes.score_path(conn, :show, "123")),
        get(conn, Routes.score_path(conn, :edit, "123")),
        put(conn, Routes.score_path(conn, :update, "123", %{})),
        post(conn, Routes.score_path(conn, :create, %{})),
        delete(conn, Routes.score_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "scores (logged in)" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)
      game = game_fixture()

      {:ok, conn: conn, user: user, game: game}
    end

    test "create score screen shows active players only", %{conn: conn, game: game} do
      player1 = player_fixture(%{name: "Bobby"})
      player2 = player_fixture(%{name: "Jane"})
      player3 = player_fixture(%{name: "Away", active: false})

      conn = get(conn, Routes.score_path(conn, :new, game.id))
      assert String.contains?(conn.resp_body, player1.name)
      assert String.contains?(conn.resp_body, player2.name)
      refute String.contains?(conn.resp_body, player3.name)
    end

    test "score of zero is ignored", %{conn: conn, game: game} do
      player1 = player_fixture(%{name: "Bobby"})
      player2 = player_fixture(%{name: "Jane"})

      values = %{"game_id" => game.id, player1.id => 36, player2.id => 0}

      create_conn = post(conn, Routes.score_path(conn, :create_many, values))
      assert redirected_to(create_conn) == Routes.game_path(create_conn, :show, game.id)

      conn = get(conn, Routes.game_path(conn, :show, game.id))
      assert String.contains?(conn.resp_body, player1.name)
      refute String.contains?(conn.resp_body, player2.name)
    end

    test "create score screen only shows players without existing score",
         %{conn: conn, game: game} do
      player1 = player_fixture(%{name: "Bobby"})
      player2 = player_fixture(%{name: "Jane"})

      score_fixture(%{
        game_id: game.id,
        player_id: player1.id
      })

      conn = get(conn, Routes.score_path(conn, :new, game.id))
      refute String.contains?(conn.resp_body, player1.name)
      assert String.contains?(conn.resp_body, player2.name)
    end
  end
end
