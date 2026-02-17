# ExRatatui

Elixir bindings for the Rust [ratatui](https://ratatui.rs) terminal UI library, via [Rustler](https://github.com/rustler-beam/rustler) NIFs.

Build rich terminal UIs in Elixir with ratatui's layout engine, widget library, and styling system — without blocking the BEAM.

## Prerequisites

- Elixir 1.17+

Precompiled NIF binaries are available for Linux, macOS, and Windows (x86_64 and aarch64). No Rust toolchain needed.

To compile from source instead, install the [Rust toolchain](https://rustup.rs/) and set:

```sh
export EX_RATATUI_BUILD=true
```

## Installation

Add `ex_ratatui` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_ratatui, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get && mix compile` — a precompiled NIF binary for your platform will be downloaded automatically.

## How It Works

ExRatatui bridges Elixir and Rust through [Rustler](https://github.com/rustler-beam/rustler) NIFs (Native Implemented Functions):

```
Elixir structs → encode to maps → Rust NIF → decode to ratatui types → render to terminal
Terminal events → Rust NIF (DirtyIo) → encode to tuples → Elixir Event structs
```

- **Rendering:** Elixir widget structs are encoded as string-keyed maps, passed across the NIF boundary, and decoded into ratatui widget types for rendering.
- **Events:** The `poll_event` NIF runs on BEAM's DirtyIo scheduler, so event polling never blocks normal Elixir processes.
- **Terminal state:** Managed in Rust via a global mutex supporting two backends — a real crossterm terminal and a headless test backend for CI.
- **Layout:** Ratatui's constraint-based layout engine is exposed directly, computing split rectangles on the Rust side and returning them as Elixir tuples.

Precompiled binaries are provided via [rustler_precompiled](https://github.com/philss/rustler_precompiled) so users don't need the Rust toolchain.

## Quick Start

```elixir
alias ExRatatui.Layout.Rect
alias ExRatatui.Style
alias ExRatatui.Widgets.Paragraph

ExRatatui.run(fn ->
  {w, h} = ExRatatui.terminal_size()

  paragraph = %Paragraph{
    text: "Hello from ExRatatui!",
    style: %Style{fg: :green, modifiers: [:bold]},
    alignment: :center
  }

  ExRatatui.draw([{paragraph, %Rect{x: 0, y: 0, width: w, height: h}}])

  # Wait for a keypress, then exit
  ExRatatui.poll_event(5000)
end)
```

Run it with `mix run examples/hello_world.exs`.

## Widgets

### Paragraph

Text display with alignment, wrapping, and scrolling.

```elixir
%Paragraph{
  text: "Hello, world!\nSecond line.",
  style: %Style{fg: :cyan, modifiers: [:bold]},
  alignment: :center,
  wrap: true
}
```

### Block

Container with borders and title. Can wrap any other widget via the `:block` field.

```elixir
%Block{
  title: "My Panel",
  borders: [:all],
  border_type: :rounded,
  border_style: %Style{fg: :blue}
}

# Compose with other widgets:
%Paragraph{
  text: "Inside a box",
  block: %Block{title: "Title", borders: [:all]}
}
```

### List

Selectable list with highlight support.

```elixir
%List{
  items: ["Elixir", "Rust", "Haskell"],
  highlight_style: %Style{fg: :yellow, modifiers: [:bold]},
  highlight_symbol: " > ",
  selected: 0,
  block: %Block{title: " Languages ", borders: [:all]}
}
```

### Table

Table with headers, rows, and column width constraints.

```elixir
%Table{
  rows: [["Alice", "30"], ["Bob", "25"]],
  header: ["Name", "Age"],
  widths: [{:length, 15}, {:length, 10}],
  highlight_style: %Style{fg: :yellow},
  selected: 0
}
```

### Gauge

Progress bar.

```elixir
%Gauge{
  ratio: 0.75,
  label: "75%",
  gauge_style: %Style{fg: :green}
}
```

## Layout

Split areas into sub-regions using constraints:

```elixir
alias ExRatatui.Layout
alias ExRatatui.Layout.Rect

area = %Rect{x: 0, y: 0, width: 80, height: 24}

# Three-row layout: header, body, footer
[header, body, footer] = Layout.split(area, :vertical, [
  {:length, 3},
  {:min, 0},
  {:length, 1}
])

# Split body into sidebar + main
[sidebar, main] = Layout.split(body, :horizontal, [
  {:percentage, 30},
  {:percentage, 70}
])
```

Constraint types: `{:percentage, n}`, `{:length, n}`, `{:min, n}`, `{:max, n}`, `{:ratio, num, den}`.

## Events

Poll for keyboard, mouse, and resize events without blocking the BEAM:

```elixir
case ExRatatui.poll_event(100) do
  %Event.Key{code: "q", kind: "press"} ->
    :quit

  %Event.Key{code: "up", kind: "press"} ->
    :move_up

  %Event.Key{code: "j", kind: "press", modifiers: ["ctrl"]} ->
    :ctrl_j

  %Event.Resize{width: w, height: h} ->
    {:resized, w, h}

  nil ->
    :timeout
end
```

## Styles

```elixir
# Named colors
%Style{fg: :green, bg: :black}

# RGB
%Style{fg: {:rgb, 255, 100, 0}}

# 256-color indexed
%Style{fg: {:indexed, 42}}

# Modifiers
%Style{modifiers: [:bold, :italic, :underlined]}
```

## Testing

ExRatatui includes a headless test backend for CI-friendly rendering verification:

```elixir
test "renders a paragraph" do
  :ok = ExRatatui.init_test_terminal(40, 10)

  paragraph = %Paragraph{text: "Hello!"}
  :ok = ExRatatui.draw([{paragraph, %Rect{x: 0, y: 0, width: 40, height: 10}}])

  content = ExRatatui.get_buffer_content()
  assert content =~ "Hello!"
end
```

## Examples

| Example | Run | Description |
|---------|-----|-------------|
| `hello_world.exs` | `mix run examples/hello_world.exs` | Minimal paragraph display |
| `counter.exs` | `mix run examples/counter.exs` | Interactive counter with key events |
| `task_tracker.exs` | `mix run examples/task_tracker.exs` | Interactive task tracker with all widgets |

## License

MIT
