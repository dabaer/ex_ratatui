defmodule ExRatatui.FrameTest do
  use ExUnit.Case, async: true

  doctest ExRatatui.Frame

  alias ExRatatui.Frame

  test "frame struct has width and height fields" do
    frame = %Frame{width: 80, height: 24}
    assert frame.width == 80
    assert frame.height == 24
  end

  test "frame struct defaults to nil" do
    frame = %Frame{}
    assert frame.width == nil
    assert frame.height == nil
  end
end
