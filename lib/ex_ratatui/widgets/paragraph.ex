defmodule ExRatatui.Widgets.Paragraph do
  @moduledoc """
  A text display widget with optional wrapping, alignment, and scrolling.
  """

  defstruct text: "",
            style: %ExRatatui.Style{},
            block: nil,
            alignment: :left,
            wrap: false,
            scroll: {0, 0}
end
