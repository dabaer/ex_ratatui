# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **OTP App behaviour:** `ExRatatui.App` with LiveView-inspired callbacks (`mount/1`, `render/2`, `handle_event/2`, `handle_info/2`) for building supervised TUI applications
- **GenServer runtime:** `ExRatatui.Server` manages terminal lifecycle, self-scheduling event polling, and callback dispatch under OTP supervision
- **Frame struct:** `ExRatatui.Frame` carries terminal dimensions to `render/2` callbacks
- **Example app:** `examples/task_manager/` — a standalone Ecto + SQLite task manager demonstrating the App behaviour with full CRUD, filtering, and status toggling
- **Example script:** `examples/counter_app.exs` — minimal App-based counter

## [0.1.0] - 2025-02-18

### Added

- **Widgets:** Paragraph (with alignment, wrapping, scrolling), Block (borders, titles, padding), List (selectable with highlight), Table (headers, rows, column constraints), and Gauge (progress bar)
- **Layout engine:** Constraint-based area splitting via `ExRatatui.Layout.split/3` with support for `:percentage`, `:length`, `:min`, `:max`, and `:ratio` constraints
- **Event polling:** Non-blocking keyboard, mouse, and resize event handling on BEAM's DirtyIo scheduler
- **Styling system:** Named colors, RGB (`{:rgb, r, g, b}`), 256-color indexed (`{:indexed, n}`), and text modifiers (bold, italic, underlined, dim, crossed out, etc.)
- **Terminal lifecycle:** `ExRatatui.run/1` for automatic terminal init and cleanup
- **Test backend:** Headless `TestBackend` via `init_test_terminal/2` and `get_buffer_content/0` for CI-friendly rendering verification
- **Precompiled NIFs:** Via `rustler_precompiled` for Linux, macOS, and Windows (x86_64 and aarch64) — no Rust toolchain required
- **Examples:** `hello_world.exs` (minimal display), `counter.exs` (interactive key events), `task_tracker.exs` (full app with all widgets)

[Unreleased]: https://github.com/mcass19/ex_ratatui/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mcass19/ex_ratatui/releases/tag/v0.1.0
