defmodule GolfexWeb.GameControllerTest do
  use GolfexWeb.ConnCase

  @create_attrs %{date: ~D[2010-04-17], type: "some type"}
  @invalid_attrs %{date: nil, type: nil}

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.game_path(conn, :new)),
        get(conn, Routes.game_path(conn, :index)),
        get(conn, Routes.game_path(conn, :show, "123")),
        get(conn, Routes.game_path(conn, :edit, "123")),
        put(conn, Routes.game_path(conn, :update, "123", %{})),
        post(conn, Routes.game_path(conn, :create, %{})),
        delete(conn, Routes.game_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "games (logged in)" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "lists all games on index", %{conn: conn} do
      game = game_fixture(@create_attrs)

      conn = get(conn, Routes.game_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Listing Games/
      assert String.contains?(conn.resp_body, game.type)
    end

    test "creates game and redirects", %{conn: conn} do
      create_conn = post(conn, Routes.game_path(conn, :create), game: @create_attrs)

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == Routes.game_path(create_conn, :show, id)

      conn = get(conn, Routes.game_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Game"
    end

    test "does not create game and renders errors when invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @invalid_attrs)
      assert html_response(conn, 200) =~ "check the errors"
    end

    test "delete game reverts all player handicaps", %{conn: conn, user: user} do
      game = game_fixture(%{date: ~D[2019-03-11]})
      player1 = player_fixture(name: "Jo", handicap: 20.0)
      player2 = player_fixture(name: "Sam", handicap: 10.0)
      score_fixture(%{game_id: game.id, player_id: player1.id, score: 40})
      score_fixture(%{game_id: game.id, player_id: player2.id, score: 37})

      # Confirm scores recorded against game
      conn = get(conn, Routes.game_path(conn, :show, game.id))

      assert String.contains?(
               conn.resp_body,
               "#{player1.name}</td>\n            <td>40"
             )

      assert String.contains?(
               conn.resp_body,
               "#{player2.name}</td>\n            <td>37"
             )

      # Confirm handicaps were amended based on game scores
      conn =
        conn
        |> reset_conn_reassign_user(user)
        |> get(Routes.player_path(conn, :index))

      assert String.contains?(conn.resp_body, "#{player1.name}</td>\n          <td>19.0")
      assert String.contains?(conn.resp_body, "#{player2.name}</td>\n          <td>9.5")

      # Delete the game
      conn =
        conn
        |> reset_conn_reassign_user(user)
        |> delete(Routes.game_path(conn, :delete, game.id))

      # Confirm the handicaps were reverted
      conn =
        conn
        |> reset_conn_reassign_user(user)
        |> get(Routes.player_path(conn, :index))

      assert String.contains?(conn.resp_body, "#{player1.name}</td>\n          <td>20.0")
      assert String.contains?(conn.resp_body, "#{player2.name}</td>\n          <td>10.0")
    end
  end

  defp reset_conn_reassign_user(conn, user) do
    conn
    |> recycle()
    |> Map.put(:assigns, %{current_user: user})
  end
end
