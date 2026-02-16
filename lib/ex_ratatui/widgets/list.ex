defmodule ExRatatui.Widgets.List do
  @moduledoc """
  A selectable list widget.
  """

  defstruct items: [],
            style: %ExRatatui.Style{},
            block: nil,
            highlight_style: %ExRatatui.Style{},
            highlight_symbol: nil,
            selected: nil
end
