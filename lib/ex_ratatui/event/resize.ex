defmodule ExRatatui.Event.Resize do
  @moduledoc "A terminal resize event."

  @type t :: %__MODULE__{
          width: non_neg_integer() | nil,
          height: non_neg_integer() | nil
        }

  defstruct [:width, :height]
end
