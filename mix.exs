defmodule Smidge.MixProject do
  use Mix.Project

  def project do
    [
      app: :smidge,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.14.0"},
      { :inflex, "~> 2.0.0" }
    ]
  end
end
