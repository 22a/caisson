defmodule Caisson.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "post things to /execute, api doc in the readme")
  end

  post "/execute", to: Caisson.Executor

  match _ do
    send_resp(conn, 404, "that thing you just tried to do isn't supported")
  end
end
