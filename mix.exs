defmodule ExRatatui.MixProject do
  use Mix.Project

  @description "Elixir bindings for the Rust ratatui terminal UI library"
  @source_url "https://github.com/mcass19/ex_ratatui"
  @version "0.1.0"

  def project do
    [
      app: :ex_ratatui,
      description: @description,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "ExRatatui",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.36", runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md"
      },
      files: ~w(lib native priv .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "ExRatatui",
      extras: [
        "CHANGELOG.md": [title: "Changelog"]
      ],
      groups_for_modules: [
        Widgets: [
          ExRatatui.Widgets.Paragraph,
          ExRatatui.Widgets.Block,
          ExRatatui.Widgets.List,
          ExRatatui.Widgets.Table,
          ExRatatui.Widgets.Gauge
        ],
        Layout: [
          ExRatatui.Layout,
          ExRatatui.Layout.Rect
        ],
        Events: [
          ExRatatui.Event,
          ExRatatui.Event.Key,
          ExRatatui.Event.Mouse,
          ExRatatui.Event.Resize
        ],
        Style: [
          ExRatatui.Style
        ]
      ]
    ]
  end
end
