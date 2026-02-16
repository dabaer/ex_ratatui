defmodule ExRatatui.Native do
  @moduledoc false
  use Rustler,
    otp_app: :ex_ratatui,
    crate: "ex_ratatui"

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
