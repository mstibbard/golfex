defmodule GolfexWeb.PlayerControllerTest do
  use GolfexWeb.ConnCase

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.player_path(conn, :new)),
        get(conn, Routes.player_path(conn, :index)),
        get(conn, Routes.player_path(conn, :show, "123")),
        get(conn, Routes.player_path(conn, :edit, "123")),
        put(conn, Routes.player_path(conn, :update, "123", %{})),
        post(conn, Routes.player_path(conn, :create, %{}))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "players (logged in)" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "lists all players on index", %{conn: conn} do
      player_fixture()

      conn = get(conn, Routes.player_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Active Players/
      assert String.contains?(conn.resp_body, "Namey McNameface")
    end
  end
end
