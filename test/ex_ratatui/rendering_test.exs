defmodule ExRatatui.RenderingTest do
  use ExUnit.Case

  alias ExRatatui.Native
  alias ExRatatui.Layout.Rect
  alias ExRatatui.Style
  alias ExRatatui.Widgets.Paragraph

  setup do
    Native.restore_terminal()
    :ok = ExRatatui.init_test_terminal(40, 10)
    on_exit(fn -> Native.restore_terminal() end)
    :ok
  end

  describe "draw/1" do
    test "returns error when terminal not initialized" do
      Native.restore_terminal()

      paragraph = %Paragraph{text: "Hello"}
      rect = %Rect{x: 0, y: 0, width: 80, height: 24}

      result = ExRatatui.draw([{paragraph, rect}])
      assert {:error, "terminal not initialized"} = result
    end

    test "accepts paragraph with default style" do
      paragraph = %Paragraph{text: "Hello, world!"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw([{paragraph, rect}])
      assert ExRatatui.get_buffer_content() =~ "Hello, world!"
    end

    test "accepts paragraph with styled text" do
      paragraph = %Paragraph{
        text: "Styled text",
        style: %Style{fg: :green, bg: :black, modifiers: [:bold]},
        alignment: :center,
        wrap: true
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw([{paragraph, rect}])
      assert ExRatatui.get_buffer_content() =~ "Styled text"
    end

    test "accepts paragraph with RGB color" do
      paragraph = %Paragraph{
        text: "RGB colored",
        style: %Style{fg: {:rgb, 255, 100, 0}}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      assert :ok = ExRatatui.draw([{paragraph, rect}])
      assert ExRatatui.get_buffer_content() =~ "RGB colored"
    end

    test "accepts multiple widgets in one frame" do
      widgets = [
        {%Paragraph{text: "Top"}, %Rect{x: 0, y: 0, width: 40, height: 3}},
        {%Paragraph{text: "Bottom"}, %Rect{x: 0, y: 3, width: 40, height: 3}}
      ]

      assert :ok = ExRatatui.draw(widgets)
      content = ExRatatui.get_buffer_content()
      assert content =~ "Top"
      assert content =~ "Bottom"
    end

    test "accepts empty widget list" do
      assert :ok = ExRatatui.draw([])
    end
  end
end
