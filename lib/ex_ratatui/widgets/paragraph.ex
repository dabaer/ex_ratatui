defmodule ExRatatui.Widgets.Paragraph do
  @moduledoc """
  A text display widget with optional wrapping, alignment, and scrolling.

  ## Fields

    * `:text` - the text content (supports `\\n` for newlines)
    * `:style` - `%ExRatatui.Style{}` for foreground/background/modifiers
    * `:block` - optional `%ExRatatui.Widgets.Block{}` container (borders, title)
    * `:alignment` - `:left`, `:center`, or `:right`
    * `:wrap` - `true` to wrap text at widget boundary
    * `:scroll` - `{vertical, horizontal}` scroll offset

  ## Example

      %Paragraph{
        text: "Hello, world!",
        style: %Style{fg: :green, modifiers: [:bold]},
        alignment: :center,
        block: %Block{title: "Greeting", borders: [:all]}
      }
  """

  defstruct text: "",
            style: %ExRatatui.Style{},
            block: nil,
            alignment: :left,
            wrap: false,
            scroll: {0, 0}
end
