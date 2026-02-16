defmodule ExRatatui.Widgets.Table do
  @moduledoc """
  A table widget with headers, rows, and optional selection.

  ## Fields

    * `:rows` - list of rows, each row is a list of cell strings
    * `:header` - optional list of header cell strings
    * `:widths` - list of constraint tuples for column widths
      (e.g., `[{:length, 10}, {:percentage, 50}, {:min, 5}]`)
    * `:style` - `%ExRatatui.Style{}` for the table
    * `:block` - optional `%ExRatatui.Widgets.Block{}` container
    * `:highlight_style` - `%ExRatatui.Style{}` for the selected row
    * `:highlight_symbol` - string prefix for the selected row
    * `:selected` - zero-based index of the selected row, or `nil`
    * `:column_spacing` - spacing between columns (default: 1)

  ## Example

      %Table{
        rows: [["Alice", "30"], ["Bob", "25"]],
        header: ["Name", "Age"],
        widths: [{:length, 15}, {:length, 10}],
        highlight_style: %Style{fg: :yellow},
        selected: 0,
        block: %Block{title: "Users", borders: [:all]}
      }
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
