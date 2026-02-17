defmodule ExRatatui.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :ex_ratatui,
    crate: "ex_ratatui",
    base_url: "https://github.com/mcass19/ex_ratatui/releases/download/v#{version}",
    force_build: System.get_env("EX_RATATUI_BUILD") in ["1", "true"],
    version: version,
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      arm-unknown-linux-gnueabihf
      x86_64-apple-darwin
      x86_64-pc-windows-gnu
      x86_64-pc-windows-msvc
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    ),
    nif_versions: ["2.16", "2.17"]

  # Terminal lifecycle
  def init_terminal, do: :erlang.nif_error(:not_loaded)
  def restore_terminal, do: :erlang.nif_error(:not_loaded)
  def terminal_size, do: :erlang.nif_error(:not_loaded)

  # Rendering
  def draw_frame(_commands), do: :erlang.nif_error(:not_loaded)

  # Events
  def poll_event(_timeout_ms), do: :erlang.nif_error(:not_loaded)

  # Layout
  def layout_split(_area, _direction, _constraints), do: :erlang.nif_error(:not_loaded)

  # Test backend
  def init_test_terminal(_width, _height), do: :erlang.nif_error(:not_loaded)
  def get_buffer_content, do: :erlang.nif_error(:not_loaded)
end
