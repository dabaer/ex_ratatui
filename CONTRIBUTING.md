# Contributing to ExRatatui

Thanks for your interest in contributing! ExRatatui is a Rust NIF project, so
contributions touch both Elixir and Rust code. This guide will help you get set up.

## Setup

1. Clone the repo:

```sh
git clone https://github.com/mcass19/ex_ratatui.git
cd ex_ratatui
```

2. Install dependencies:

- **Elixir** 1.17+ and **Erlang/OTP** 26+
- **Rust** toolchain via [rustup](https://rustup.rs/)

3. Fetch deps and compile from source:

```sh
mix deps.get
export EX_RATATUI_BUILD=true
mix compile
```

The `EX_RATATUI_BUILD=true` env var tells the library to compile the Rust NIF
from source instead of downloading a precompiled binary.

## Running Tests

```sh
# Elixir tests (includes doctests)
mix test

# Rust tests
cargo test --manifest-path native/ex_ratatui/Cargo.toml
```


## Code Quality

Before submitting a PR, make sure the following pass:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix dialyzer
mix rust.check
```

`mix rust.check` runs `cargo fmt --check`, `cargo clippy`, and `cargo test`.

CI runs all of these across Elixir 1.17/1.18/1.19 with Erlang 26/27/28.

## Project Structure

```
lib/ex_ratatui.ex          # Main API + widget encoding
lib/ex_ratatui/app.ex      # OTP App behaviour
lib/ex_ratatui/server.ex   # GenServer managing the event loop
lib/ex_ratatui/native.ex   # NIF bindings (RustlerPrecompiled)
lib/ex_ratatui/widgets/    # Widget struct definitions
lib/ex_ratatui/event/      # Event structs (Key, Mouse, Resize)
lib/ex_ratatui/layout.ex   # Layout splitting
lib/ex_ratatui/style.ex    # Style/color types

native/ex_ratatui/src/
  lib.rs                   # NIF registration
  terminal.rs              # Terminal lifecycle + ResourceArc
  rendering.rs             # Widget decoding + draw orchestration
  events.rs                # Event polling (DirtyIo)
  layout.rs                # Constraint-based layout
  style.rs                 # Color/modifier decoding
  widgets/                 # Widget builders
```

## Pull Requests

- Keep PRs focused — one feature or fix per PR
- Add tests for new functionality
- Update documentation (moduledocs, README if applicable)
- Follow existing code style and patterns
- Ensure CI passes before requesting review
