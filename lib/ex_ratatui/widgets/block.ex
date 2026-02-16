defmodule ExRatatui.Widgets.Block do
  @moduledoc """
  A container widget that provides borders and a title around other widgets.

  Can be rendered standalone or used as the `:block` field on other widgets
  (Paragraph, List, Table, Gauge) for composition.

  ## Fields

    * `:title` - optional title string displayed on the top border
    * `:borders` - list of border sides: `:all`, `:top`, `:right`, `:bottom`, `:left`
    * `:border_style` - `%ExRatatui.Style{}` for border color/modifiers
    * `:border_type` - `:plain`, `:rounded`, `:double`, or `:thick`
    * `:style` - `%ExRatatui.Style{}` for the inner area
    * `:padding` - `{left, right, top, bottom}` inner padding

  ## Example

      %Block{
        title: "My Panel",
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :cyan}
      }
  """

  defstruct title: nil,
            borders: [],
            border_style: %ExRatatui.Style{},
            border_type: :plain,
            style: %ExRatatui.Style{},
            padding: {0, 0, 0, 0}
end
