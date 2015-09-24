defmodule Router do
  use Plug.Router
  import Plug.Conn
  use Plug.Builder

  plug Plug.Static, at: "/", from: :blog
  plug :match
  plug :dispatch

  get _ do
    case parse_url(conn.path_info) |> Template.render() do
      {:ok, body} -> send_resp(conn, 200, body)
      {:error, _} -> send_resp(conn, 404, "oops")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def parse_url(url) do
    url
  end

  def start(opts \\ []) do
    Plug.Adapters.Cowboy.http __MODULE__, opts
  end

  def start_link(opts \\ []) do
    start(opts)
  end
end