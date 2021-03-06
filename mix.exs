defmodule Blog.Mixfile do
  use Mix.Project

  def project do
    [app: :blog,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Blog, []},
     applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:earmark, "~> 0.1.17"},]
  end
end
