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

  @type t :: %__MODULE__{
          text: String.t(),
          style: ExRatatui.Style.t(),
          block: ExRatatui.Widgets.Block.t() | nil,
          alignment: :left | :center | :right,
          wrap: boolean(),
          scroll: {non_neg_integer(), non_neg_integer()}
        }

  defstruct text: "",
            style: %ExRatatui.Style{},
            block: nil,
            alignment: :left,
            wrap: false,
            scroll: {0, 0}
end
