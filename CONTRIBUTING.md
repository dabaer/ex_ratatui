# Contributing to ExRatatui

Thanks for your interest in contributing!

ExRatatui is a Rust NIF project, so contributions touch both Elixir and Rust code.

This guide will help you get set up.

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

## Pull Requests

Before submitting a PR, make sure the following pass:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix dialyzer
mix rust.check
```

- Keep PRs focused — one feature or fix per PR
- Add tests for new functionality
- Update documentation (moduledocs, CHANGELOG, README if applicable)
- Follow existing code style and patterns
- Ensure CI passes before requesting review
