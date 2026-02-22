defmodule ExRatatui.Event.Mouse do
  @moduledoc "A mouse event."

  @type t :: %__MODULE__{
          kind: String.t() | nil,
          button: String.t() | nil,
          x: non_neg_integer() | nil,
          y: non_neg_integer() | nil,
          modifiers: [String.t()]
        }

  defstruct [:kind, :button, :x, :y, modifiers: []]
end
