defmodule ExRatatui.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_ratatui,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "ExRatatui",
      extras: ["NEXT_STEPS.md"],
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

  defp deps do
    [
      {:rustler, "~> 0.36", runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end
end
