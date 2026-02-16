defmodule ExRatatui do
  @moduledoc """
  Ratatui TUI library bindings for Elixir.

  Provides terminal UI capabilities via Rust NIFs wrapping the ratatui crate.
  """

  alias ExRatatui.Native

  @doc """
  Runs a TUI application.

  Initializes the terminal, calls `fun`, and ensures terminal cleanup on exit.

      ExRatatui.run(fn ->
        # your TUI loop here
      end)
  """
  def run(opts \\ [], fun) when is_function(fun, 0) do
    _viewport = Keyword.get(opts, :viewport, :fullscreen)
    Native.init_terminal()

    try do
      fun.()
    after
      Native.restore_terminal()
    end
  end

  @doc """
  Draws a list of `{widget, rect}` tuples to the terminal in a single frame.
  """
  def draw(widgets) when is_list(widgets) do
    Native.draw_frame(widgets)
  end

  @doc """
  Polls for terminal events with a timeout (default 250ms).

  Returns an event struct or `nil` if no event within the timeout.
  """
  def poll_event(timeout_ms \\ 250) do
    case Native.poll_event(timeout_ms) do
      nil -> nil
      raw -> ExRatatui.Event.from_raw(raw)
    end
  end

  @doc """
  Returns the current terminal size as `{width, height}`.
  """
  def terminal_size do
    Native.terminal_size()
  end
end
