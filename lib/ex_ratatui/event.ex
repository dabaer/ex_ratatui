defmodule ExRatatui.Event do
  @moduledoc """
  Terminal event structs.

  Events are returned by `ExRatatui.poll_event/1` and can be pattern matched.
  """

  defmodule Key do
    @moduledoc "A keyboard event."
    defstruct [:code, :modifiers, :kind]
  end

  defmodule Mouse do
    @moduledoc "A mouse event."
    defstruct [:kind, :button, :x, :y, :modifiers]
  end

  defmodule Resize do
    @moduledoc "A terminal resize event."
    defstruct [:width, :height]
  end

  @doc false
  def from_raw(%{"type" => "key"} = raw) do
    %Key{
      code: raw["code"],
      modifiers: raw["modifiers"] || [],
      kind: raw["kind"]
    }
  end

  def from_raw(%{"type" => "mouse"} = raw) do
    %Mouse{
      kind: raw["kind"],
      button: raw["button"],
      x: raw["x"],
      y: raw["y"],
      modifiers: raw["modifiers"] || []
    }
  end

  def from_raw(%{"type" => "resize"} = raw) do
    %Resize{
      width: raw["width"],
      height: raw["height"]
    }
  end

  def from_raw(_other), do: nil
end
