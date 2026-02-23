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

  ## Examples

      iex> %ExRatatui.Widgets.Table{
      ...>   rows: [["Alice", "30"], ["Bob", "25"]],
      ...>   header: ["Name", "Age"],
      ...>   widths: [{:length, 15}, {:length, 10}]
      ...> }
      %ExRatatui.Widgets.Table{
        rows: [["Alice", "30"], ["Bob", "25"]],
        header: ["Name", "Age"],
        widths: [length: 15, length: 10],
        style: %ExRatatui.Style{},
        block: nil,
        highlight_style: %ExRatatui.Style{},
        highlight_symbol: nil,
        selected: nil,
        column_spacing: 1
      }
  """

  @type t :: %__MODULE__{
          rows: [[String.t()]],
          header: [String.t()] | nil,
          widths: [ExRatatui.Layout.constraint()],
          style: ExRatatui.Style.t(),
          block: ExRatatui.Widgets.Block.t() | nil,
          highlight_style: ExRatatui.Style.t(),
          highlight_symbol: String.t() | nil,
          selected: non_neg_integer() | nil,
          column_spacing: non_neg_integer()
        }

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
