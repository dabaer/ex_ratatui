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

  ## Examples

      iex> %ExRatatui.Widgets.Paragraph{text: "Hello!", alignment: :center}
      %ExRatatui.Widgets.Paragraph{
        text: "Hello!",
        style: %ExRatatui.Style{},
        block: nil,
        alignment: :center,
        wrap: false,
        scroll: {0, 0}
      }

      iex> alias ExRatatui.Widgets.{Paragraph, Block}
      iex> alias ExRatatui.Style
      iex> %Paragraph{
      ...>   text: "Hello, world!",
      ...>   style: %Style{fg: :green, modifiers: [:bold]},
      ...>   alignment: :center,
      ...>   block: %Block{title: "Greeting", borders: [:all]}
      ...> }
      %ExRatatui.Widgets.Paragraph{
        text: "Hello, world!",
        style: %ExRatatui.Style{fg: :green, modifiers: [:bold]},
        block: %ExRatatui.Widgets.Block{title: "Greeting", borders: [:all]},
        alignment: :center,
        wrap: false,
        scroll: {0, 0}
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
