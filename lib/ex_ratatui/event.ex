defmodule ExRatatui.Event do
  @moduledoc """
  Terminal event structs.

  Events are returned by `ExRatatui.poll_event/1` and can be pattern matched.
  """

  defmodule Key do
    @moduledoc "A keyboard event."

    @type t :: %__MODULE__{
            code: String.t() | nil,
            modifiers: [String.t()],
            kind: String.t() | nil
          }

    defstruct [:code, :kind, modifiers: []]
  end

  defmodule Mouse do
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

  defmodule Resize do
    @moduledoc "A terminal resize event."

    @type t :: %__MODULE__{
            width: non_neg_integer() | nil,
            height: non_neg_integer() | nil
          }

    defstruct [:width, :height]
  end
end
