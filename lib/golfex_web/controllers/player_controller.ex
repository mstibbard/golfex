defmodule GolfexWeb.PlayerController do
  use GolfexWeb, :controller

  alias Golfex.Players
  alias Golfex.Players.Player
  alias Golfex.Scores

  def index(conn, _params) do
    players = Players.list_players()
    render(conn, "index.html", players: players)
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player(id)
    scores = Scores.get_scores_by_player_id!(id)
    render(conn, "show.html", player: player, scores: scores)
  end

  def new(conn, _params) do
    changeset = Players.change_player(%Player{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Players.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "#{player.name} created!")
        |> redirect(to: Routes.player_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    player = Players.get_player(id)
    changeset = Players.change_player(player)
    render(conn, "edit.html", player: player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Players.get_player!(id)

    case Players.update_player(player, player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", player: player, changeset: changeset)
    end
  end
end
