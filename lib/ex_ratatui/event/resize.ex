defmodule ExRatatui.Event.Resize do
  @moduledoc """
  A terminal resize event.

  Emitted when the user resizes the terminal window.

  ## Fields

    * `:width` - new terminal width in columns
    * `:height` - new terminal height in rows

  ## Example

      %Event.Resize{width: w, height: h} ->
        # re-render with new dimensions
  """

  @type t :: %__MODULE__{
          width: non_neg_integer() | nil,
          height: non_neg_integer() | nil
        }

  defstruct [:width, :height]
end
