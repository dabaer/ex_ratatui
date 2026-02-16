defmodule ExRatatui.Text do
  @moduledoc """
  Text primitives for styled terminal output.
  """

  defmodule Span do
    @moduledoc "A styled segment of text within a line."
    defstruct content: "", style: %ExRatatui.Style{}
  end

  defmodule Line do
    @moduledoc "A line of styled spans."
    defstruct spans: [], alignment: :left
  end
end
