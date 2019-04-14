defmodule SimplexFormat.MixProject do
  use Mix.Project

  def project do
    [
      app: :simplex_format,
      version: "0.1.2",
      elixir: "~> 1.7",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "simplex_format",
      source_url: "https://github.com/poplarhq/simplex_format"
    ]
  end

  defp description do
    "Converts plain text to formatted HTML, including automatically linking URLs"
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/poplarhq/simplex_format"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_html, "~> 2.11"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
