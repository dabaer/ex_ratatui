# Example: interactive counter with key events.
# Run with: mix run examples/counter.exs
#
# Controls: Up/k = increment, Down/j = decrement, q = quit

alias ExRatatui.Layout.Rect
alias ExRatatui.Style
alias ExRatatui.Widgets.Paragraph
alias ExRatatui.Event

defmodule Counter do
  def run do
    ExRatatui.run(fn ->
      loop(0)
    end)
  end

  defp loop(count) do
    {w, h} = ExRatatui.terminal_size()

    paragraph = %Paragraph{
      text: "Counter: #{count}\n\nUp/k = +1  |  Down/j = -1  |  q = quit",
      style: %Style{fg: :cyan, modifiers: [:bold]},
      alignment: :center
    }

    ExRatatui.draw([{paragraph, %Rect{x: 0, y: 0, width: w, height: h}}])

    case ExRatatui.poll_event(100) do
      %Event.Key{code: "q", kind: "press"} ->
        :ok

      %Event.Key{code: code, kind: "press"} when code in ["up", "k"] ->
        loop(count + 1)

      %Event.Key{code: code, kind: "press"} when code in ["down", "j"] ->
        loop(count - 1)

      _ ->
        loop(count)
    end
  end
end

Counter.run()
