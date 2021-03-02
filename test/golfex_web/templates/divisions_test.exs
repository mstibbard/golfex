defmodule GolfexWeb.DivisionsTest do
  use GolfexWeb.ConnCase, async: true

  describe "divisions" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "handicaps are rounded correctly", %{conn: conn} do
      p1 = player_fixture(%{name: "Jo", handicap: 31.5})
      p2 = player_fixture(%{name: "Hum", handicap: 31.4})

      conn = get(conn, Routes.page_path(conn, :index))
      assert String.contains?(conn.resp_body, "#{p1.name}</td><td>32")
      assert String.contains?(conn.resp_body, "#{p2.name}</td><td>31")
    end
  end
end
