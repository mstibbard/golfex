defmodule GolfexWeb.PageController do
  use GolfexWeb, :controller

  alias Golfex.Players

  @div1_max 32
  @div2_min 33
  @div2_max 41
  @div3_min 42

  def index(conn, _params) do
    div1 = Players.get_division(0, @div1_max)
    div2 = Players.get_division(@div2_min, @div2_max)
    div3 = Players.get_division(@div3_min, 100)
    headers = %{d1: @div1_max, d2_min: @div2_min, d2_max: @div2_max, d3: @div3_min}

    render(conn, "index.html", div1: div1, div2: div2, div3: div3, headers: headers)
  end

  def print(conn, _params) do
    div1 = Players.get_division(0, @div1_max)
    div2 = Players.get_division(@div2_min, @div2_max)
    div3 = Players.get_division(@div3_min, 100)
    headers = %{d1: @div1_max, d2_min: @div2_min, d2_max: @div2_max, d3: @div3_min}

    render(conn, "print.html", div1: div1, div2: div2, div3: div3, headers: headers)
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
