defmodule ExRatatui.Widgets.List do
  @moduledoc """
  A selectable list widget.

  ## Fields

    * `:items` - list of strings to display
    * `:style` - `%ExRatatui.Style{}` for non-selected items
    * `:block` - optional `%ExRatatui.Widgets.Block{}` container
    * `:highlight_style` - `%ExRatatui.Style{}` for the selected item
    * `:highlight_symbol` - string prefix for the selected item (e.g., `">> "`)
    * `:selected` - zero-based index of the selected item, or `nil` for no selection

  ## Examples

      iex> %ExRatatui.Widgets.List{items: ["Alpha", "Beta", "Gamma"], selected: 0}
      %ExRatatui.Widgets.List{
        items: ["Alpha", "Beta", "Gamma"],
        style: %ExRatatui.Style{},
        block: nil,
        highlight_style: %ExRatatui.Style{},
        highlight_symbol: nil,
        selected: 0
      }
  """

  @type t :: %__MODULE__{
          items: [String.t()],
          style: ExRatatui.Style.t(),
          block: ExRatatui.Widgets.Block.t() | nil,
          highlight_style: ExRatatui.Style.t(),
          highlight_symbol: String.t() | nil,
          selected: non_neg_integer() | nil
        }

  defstruct items: [],
            style: %ExRatatui.Style{},
            block: nil,
            highlight_style: %ExRatatui.Style{},
            highlight_symbol: nil,
            selected: nil
end
