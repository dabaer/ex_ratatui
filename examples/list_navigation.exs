# Example: navigable list with keyboard controls.
# Run with: mix run examples/list_navigation.exs
#
# Controls: Up/k = previous, Down/j = next, q = quit

alias ExRatatui.Layout
alias ExRatatui.Layout.Rect
alias ExRatatui.Style
alias ExRatatui.Widgets.{Block, List, Paragraph}
alias ExRatatui.Event

defmodule ListNav do
  @items [
    "Elixir",
    "Rust",
    "Haskell",
    "OCaml",
    "Erlang",
    "Gleam",
    "Zig",
    "Go",
    "Python",
    "Ruby"
  ]

  def run do
    ExRatatui.run(fn ->
      loop(0)
    end)
  end

  defp loop(selected) do
    {w, h} = ExRatatui.terminal_size()
    area = %Rect{x: 0, y: 0, width: w, height: h}

    [list_area, status_area] =
      Layout.split(area, :vertical, [{:min, 0}, {:length, 1}])

    list = %List{
      items: @items,
      highlight_style: %Style{fg: :yellow, modifiers: [:bold]},
      highlight_symbol: " → ",
      selected: selected,
      block: %Block{
        title: " Languages ",
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :cyan}
      }
    }

    status = %Paragraph{
      text: " ↑/k up  ↓/j down  q quit │ selected: #{Enum.at(@items, selected)}",
      style: %Style{fg: :dark_gray}
    }

    ExRatatui.draw([{list, list_area}, {status, status_area}])

    case ExRatatui.poll_event(100) do
      %Event.Key{code: "q", kind: "press"} ->
        :ok

      %Event.Key{code: code, kind: "press"} when code in ["up", "k"] ->
        loop(max(selected - 1, 0))

      %Event.Key{code: code, kind: "press"} when code in ["down", "j"] ->
        loop(min(selected + 1, length(@items) - 1))

      _ ->
        loop(selected)
    end
  end
end

ListNav.run()
