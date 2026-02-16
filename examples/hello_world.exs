# Example: renders a paragraph and waits for any key to exit.
# Run with: mix run examples/hello_world.exs

alias ExRatatui.Layout.Rect
alias ExRatatui.Style
alias ExRatatui.Widgets.Paragraph

ExRatatui.run(fn ->
  {w, h} = ExRatatui.terminal_size()

  paragraph = %Paragraph{
    text: "Hello from ExRatatui! Press Ctrl+C to exit.",
    style: %Style{fg: :green, modifiers: [:bold]},
    alignment: :center
  }

  ExRatatui.draw([{paragraph, %Rect{x: 0, y: 0, width: w, height: h}}])
end)
