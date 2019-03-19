defmodule GolfexWeb.Router do
  use GolfexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GolfexWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/manage", GolfexWeb do
    pipe_through([:browser, :authenticate_user])

    resources("/players", PlayerController, except: [:delete])

    get("/print", PageController, :print)
    get("/awards", PageController, :awards)

    resources("/games", GameController)
    resources("/games/score", ScoreController, except: [:new])
    get("/games/score/new/:id", ScoreController, :new)
    post("/games/score/create_many", ScoreController, :create_many)
    resources("/users", UserController, only: [:index, :show])
  end

  scope "/", GolfexWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources("/users", UserController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create, :delete])
  end
end
