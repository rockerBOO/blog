defmodule Blog do
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Router, []),
    ]

    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
