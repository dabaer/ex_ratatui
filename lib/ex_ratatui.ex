defmodule ExRatatui do
  @moduledoc """
  Ratatui TUI library bindings for Elixir.

  Provides terminal UI capabilities via Rust NIFs wrapping the ratatui crate.
  """

  alias ExRatatui.Native
  alias ExRatatui.Layout.Rect
  alias ExRatatui.Style
  alias ExRatatui.Widgets.Paragraph

  @doc """
  Runs a TUI application.

  Initializes the terminal, calls `fun`, and ensures terminal cleanup on exit.

      ExRatatui.run(fn ->
        # your TUI loop here
      end)
  """
  def run(opts \\ [], fun) when is_function(fun, 0) do
    _viewport = Keyword.get(opts, :viewport, :fullscreen)

    case Native.init_terminal() do
      :ok ->
        try do
          fun.()
        after
          Native.restore_terminal()
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Draws a list of `{widget, rect}` tuples to the terminal in a single frame.

  Returns `:ok` on success or `{:error, reason}` on failure.

      ExRatatui.draw([
        {%ExRatatui.Widgets.Paragraph{text: "Hello!"}, rect}
      ])
  """
  def draw(widgets) when is_list(widgets) do
    commands = Enum.map(widgets, &encode_command/1)
    Native.draw_frame(commands)
  end

  @doc """
  Polls for terminal events with a timeout (default 250ms).

  Returns an `Event.Key`, `Event.Mouse`, `Event.Resize` struct, or `nil`
  if no event within the timeout.
  """
  def poll_event(timeout_ms \\ 250) do
    alias ExRatatui.Event

    case Native.poll_event(timeout_ms) do
      nil ->
        nil

      {:key, code, modifiers, kind} ->
        %Event.Key{code: code, modifiers: modifiers, kind: kind}

      {:mouse, kind, button, x, y, modifiers} ->
        %Event.Mouse{kind: kind, button: button, x: x, y: y, modifiers: modifiers}

      {:resize, width, height} ->
        %Event.Resize{width: width, height: height}

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Returns the current terminal size as `{width, height}`.

  Returns `{:error, reason}` if the terminal size cannot be determined.
  """
  def terminal_size do
    case Native.terminal_size() do
      {w, h} when is_integer(w) and is_integer(h) -> {w, h}
      {:error, _} = err -> err
    end
  end

  # -- Encoding: Elixir structs → string-keyed maps for NIF --

  defp encode_command({widget, %Rect{} = rect}) do
    {encode_widget(widget), encode_rect(rect)}
  end

  defp encode_widget(%Paragraph{} = p) do
    %{
      "type" => "paragraph",
      "text" => p.text,
      "style" => encode_style(p.style),
      "alignment" => Atom.to_string(p.alignment),
      "wrap" => p.wrap,
      "scroll_y" => elem(p.scroll, 0),
      "scroll_x" => elem(p.scroll, 1)
    }
  end

  defp encode_style(%Style{} = s) do
    style = %{"modifiers" => Enum.map(s.modifiers, &Atom.to_string/1)}
    style = if s.fg, do: Map.put(style, "fg", encode_color(s.fg)), else: style
    if s.bg, do: Map.put(style, "bg", encode_color(s.bg)), else: style
  end

  defp encode_color(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp encode_color({:rgb, r, g, b}), do: %{"type" => "rgb", "r" => r, "g" => g, "b" => b}
  defp encode_color({:indexed, i}), do: %{"type" => "indexed", "value" => i}

  defp encode_rect(%Rect{} = r) do
    %{"x" => r.x, "y" => r.y, "width" => r.width, "height" => r.height}
  end
end
