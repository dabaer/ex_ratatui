defmodule ExRatatui.Widgets.Table do
  @moduledoc """
  A table widget with headers and rows.
  """

  defstruct rows: [],
            header: nil,
            widths: [],
            style: %ExRatatui.Style{},
            block: nil,
            highlight_style: %ExRatatui.Style{},
            highlight_symbol: nil,
            selected: nil,
            column_spacing: 1
end
