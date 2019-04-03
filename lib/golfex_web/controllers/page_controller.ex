defmodule GolfexWeb.PageController do
  use GolfexWeb, :controller

  alias Golfex.Players

  def index(conn, _params) do
    div1 = Players.get_division(0, 27.4)
    div2 = Players.get_division(27.5, 36.4)
    div3 = Players.get_division(36.5, 100)
    render(conn, "index.html", div1: div1, div2: div2, div3: div3)
  end

  def print(conn, _params) do
    div1 = Players.get_division(0, 27.4)
    div2 = Players.get_division(27.5, 36.4)
    div3 = Players.get_division(36.5, 100)

    render(conn, "print.html", div1: div1, div2: div2, div3: div3)
  end

  def awards(conn, _params) do
    now = Date.utc_today()
    attendance = Players.get_attendance(now.year)
    stableford = Players.get_stableford(now.year)

    render(
      conn,
      "awards.html",
      year: now.year,
      attendance: attendance,
      stableford: stableford
    )
  end
end
