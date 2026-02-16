defmodule ExRatatui.Widgets.Block do
  @moduledoc """
  A container widget that provides borders and a title around other widgets.
  """

  defstruct title: nil,
            borders: [],
            border_style: %ExRatatui.Style{},
            border_type: :plain,
            style: %ExRatatui.Style{},
            padding: {0, 0, 0, 0}
end
