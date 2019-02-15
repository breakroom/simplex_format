defmodule SimpleFormat.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_format,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "simple_format",
      source_url: "https://github.com/poplarhq/simple_format"
    ]
  end

  defp description do
    "Convert plain text to formatted HTML, including automatically linking URLs"
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/poplarhq/simple_format"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_html, "~> 2.11"}
    ]
  end
end
