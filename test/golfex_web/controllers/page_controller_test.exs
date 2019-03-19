defmodule GolfexWeb.PageControllerTest do
  use GolfexWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200) =~
             "Please sign in or create an account. You will then be able to manage the players, handicaps, and games."
  end

  test "requires user authentication on all actions", %{conn: conn} do
    # Excludes :index as this loads different content for auth/unauth users
    Enum.each(
      [
        get(conn, Routes.page_path(conn, :print)),
        get(conn, Routes.page_path(conn, :awards))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "awards (logged in)" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "divisions page shows 3 headings", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      assert String.contains?(conn.resp_body, "Division 1")
      assert String.contains?(conn.resp_body, "Division 2")
      assert String.contains?(conn.resp_body, "Division 3")
    end

    test "awards page shows attendance and stableford", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :awards))
      assert String.contains?(conn.resp_body, "Attendance Points")
      assert String.contains?(conn.resp_body, "Stableford Award")
    end
  end
end
