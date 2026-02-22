defmodule ExRatatui.Event do
  @moduledoc """
  Terminal event structs.

  Events are returned by `ExRatatui.poll_event/1` and can be pattern matched.
  """

  @type t :: ExRatatui.Event.Key.t() | ExRatatui.Event.Mouse.t() | ExRatatui.Event.Resize.t()
end
