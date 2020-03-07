defmodule Mauricio.MixProject do
  use Mix.Project

  def project do
    [
      app: :mauricio,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:nadia],
      extra_applications: [:logger],
      mod: {Mauricio, []},
      start_phases: [setup_webhook: []],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.6.0"},
      {:elli, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:bookish_spork, github: "tank-bohr/bookish_spork", only: :test},
      {:ex_parameterized, "~> 1.3.7", only: :test},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:rename, "~> 0.1.0", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
