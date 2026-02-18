# Contributing to ExRatatui

Thank you for considering contributing! All kinds of contributions are welcome — bug reports, feature ideas, documentation, and code.

## Reporting Bugs

Before opening an issue:

- Check [existing issues](https://github.com/mcass19/ex_ratatui/issues) to avoid duplicates
- Verify the bug is reproducible on the latest `main`

Please include:

- Elixir and OTP versions (`elixir --version`)
- Operating system and architecture
- A minimal reproduction case

## Suggesting Features

Open a [GitHub issue](https://github.com/mcass19/ex_ratatui/issues/new) describing:

- The use case you're trying to solve
- Your proposed approach (if you have one)
- Any relevant examples from ratatui's Rust API

## Pull Requests

1. Fork the repository and create a branch from `main`
2. Write or update tests that cover your change
3. Run the test suite: `mix test`
4. Run the formatter: `mix format`
5. Update `CHANGELOG.md` under the `[Unreleased]` section
6. Open a PR with a clear description of what changed and why

## Development Setup

### Elixir only (uses precompiled NIF)

```sh
git clone https://github.com/mcass19/ex_ratatui.git
cd ex_ratatui
mix deps.get
mix test
```

### With Rust (compile NIF from source)

Install the [Rust toolchain](https://rustup.rs/), then:

```sh
export EX_RATATUI_BUILD=true
mix deps.get
mix compile
mix test
```

## Code Style

- Run `mix format` before committing
- Follow the patterns already in the codebase
- Keep NIF-facing code in `lib/ex_ratatui/native.ex`
- Widget structs go in `lib/ex_ratatui/widgets/`

## License

By contributing, you agree that your work will be released under the [MIT License](LICENSE).
