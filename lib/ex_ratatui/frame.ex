defmodule ExRatatui.Frame do
  @moduledoc """
  Terminal frame information passed to `render/2` callbacks.

  Contains the current terminal dimensions.

  ## Examples

      iex> %ExRatatui.Frame{width: 80, height: 24}
      %ExRatatui.Frame{width: 80, height: 24}
  """

  @type t :: %__MODULE__{
          width: non_neg_integer() | nil,
          height: non_neg_integer() | nil
        }

  defstruct [:width, :height]
end
