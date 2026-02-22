defmodule ExRatatui.Event.Key do
  @moduledoc "A keyboard event."

  @type t :: %__MODULE__{
          code: String.t() | nil,
          modifiers: [String.t()],
          kind: String.t() | nil
        }

  defstruct [:code, :kind, modifiers: []]
end
