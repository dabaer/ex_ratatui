defmodule ExRatatui.Widgets.Gauge do
  @moduledoc """
  A progress bar widget.
  """

  defstruct ratio: 0.0,
            label: nil,
            style: %ExRatatui.Style{},
            block: nil,
            gauge_style: %ExRatatui.Style{}
end
