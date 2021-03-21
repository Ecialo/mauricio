defmodule Mauricio.MixProject do
  use Mix.Project

  def project do
    [
      app: :mauricio,
      version: "0.2.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # applications: applications(Mix.env()),
      extra_applications: [
        :logger,
        :runtime_tools,
        :eex
      ],
      mod: {Mauricio, []},
      start_phases: [setup_webhook: []]
    ]
  end

  def applications(:test) do
    applications(:default) ++ [:proper, :propcheck]
  end

  def applications(_) do
    [
      :nadia,
      :mongodb_driver,
      :elli,
      :jason
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/test_data"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elli, "~> 3.2"},
      {:nadia, "~> 0.6.0"},
      {:jason, "~> 1.1"},
      {:mongodb_driver, "~> 0.7"},
      {:floki, "~> 0.28.0"},
      {:timex, "~> 3.6.4"},
      {:quantum, "~> 3.0"},
      {:murmur, "~> 1.0"},
      {:bookish_spork, github: "tank-bohr/bookish_spork", only: :test},
      {:ex_parameterized, "~> 1.3.7", only: :test},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:rename, "~> 0.1.0", only: :dev},
      {:excoveralls, "~> 0.12.3", only: :test},
      {:propcheck, "~> 1.1", only: [:test, :dev]},
      {:ex_doc, "~> 0.21.3", dev: true, runtime: false},
      {:credo, "~> 1.4.0", only: :dev, runtime: false},
      {:benchee, "~> 1.0.1", only: :dev}
    ]
  end
end
