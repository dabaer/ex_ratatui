# Architecture & Roadmap

## Architecture

ExRatatui bridges Elixir and the Rust [ratatui](https://ratatui.rs) TUI library via [Rustler](https://github.com/rustler-beam/rustler) NIFs.

```
Elixir structs  ──encode──>  string-keyed maps  ──NIF──>  Rust decode  ──>  ratatui widgets
     %Paragraph{}                %{"type" => ...}              ParagraphData        Paragraph::new(...)
```

### Data flow

1. **Elixir side** — widgets are plain structs (`%Paragraph{}`, `%List{}`, etc.). `ExRatatui.draw/1` encodes them into string-keyed maps and passes them to the NIF.
2. **Rust NIF** — decodes maps into owned Rust structs (`ParagraphData`, `ListData`, etc.) before the `terminal.draw()` closure, avoiding `Term` lifetime issues.
3. **Rendering** — dispatches to per-widget render functions that construct ratatui widgets and call `frame.render_widget()` or `frame.render_stateful_widget()`.

### Terminal backend

The global terminal state uses an `AnyTerminal` enum that supports both:
- **Crossterm** — real terminal via `init_terminal/0`
- **TestBackend** — headless rendering via `init_test_terminal/2` for CI-friendly testing

### Event polling

`poll_event/1` runs on a Dirty I/O scheduler (`#[rustler::nif(schedule = "DirtyIo")]`) so it never blocks the BEAM. Events are returned as tagged tuples via `NifTaggedEnum` and wrapped into Elixir structs.

