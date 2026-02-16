defmodule ExRatatui.RenderingTest do
  use ExUnit.Case

  alias ExRatatui.Native
  alias ExRatatui.Layout.Rect
  alias ExRatatui.Style
  alias ExRatatui.Widgets.Paragraph

  setup do
    # Ensure clean terminal state
    Native.restore_terminal()
    :ok
  end

  describe "draw/1" do
    test "returns error when terminal not initialized" do
      paragraph = %Paragraph{text: "Hello"}
      rect = %Rect{x: 0, y: 0, width: 80, height: 24}

      result = ExRatatui.draw([{paragraph, rect}])
      assert {:error, "terminal not initialized"} = result
    end

    test "accepts paragraph with default style" do
      paragraph = %Paragraph{text: "Hello, world!"}
      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      case Native.init_terminal() do
        :ok ->
          assert :ok = ExRatatui.draw([{paragraph, rect}])
          Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "accepts paragraph with styled text" do
      paragraph = %Paragraph{
        text: "Styled text",
        style: %Style{fg: :green, bg: :black, modifiers: [:bold]},
        alignment: :center,
        wrap: true
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      case Native.init_terminal() do
        :ok ->
          assert :ok = ExRatatui.draw([{paragraph, rect}])
          Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "accepts paragraph with RGB color" do
      paragraph = %Paragraph{
        text: "RGB colored",
        style: %Style{fg: {:rgb, 255, 100, 0}}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 5}

      case Native.init_terminal() do
        :ok ->
          assert :ok = ExRatatui.draw([{paragraph, rect}])
          Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "accepts multiple widgets in one frame" do
      widgets = [
        {%Paragraph{text: "Top"}, %Rect{x: 0, y: 0, width: 40, height: 3}},
        {%Paragraph{text: "Bottom"}, %Rect{x: 0, y: 3, width: 40, height: 3}}
      ]

      case Native.init_terminal() do
        :ok ->
          assert :ok = ExRatatui.draw(widgets)
          Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "accepts empty widget list" do
      case Native.init_terminal() do
        :ok ->
          assert :ok = ExRatatui.draw([])
          Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end
  end
end
