defmodule ExRatatui.WidgetsTest do
  use ExUnit.Case

  alias ExRatatui.Native
  alias ExRatatui.Layout.Rect
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Gauge, List, Paragraph, Table}

  setup do
    Native.restore_terminal()
    :ok
  end

  # Helper: run draw within an init_terminal/restore_terminal pair.
  # Handles both TTY and non-TTY environments.
  defp with_draw(widgets) do
    case Native.init_terminal() do
      :ok ->
        result = ExRatatui.draw(widgets)
        Native.restore_terminal()
        {:drew, result}

      {:error, _} ->
        :no_tty
    end
  end

  describe "Block widget" do
    test "encoding a standalone block does not raise" do
      block = %Block{
        title: "My Block",
        borders: [:all],
        border_type: :rounded,
        style: %Style{fg: :white}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      case with_draw([{block, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "block with individual borders" do
      block = %Block{borders: [:top, :bottom], border_type: :plain}
      rect = %Rect{x: 0, y: 0, width: 20, height: 5}

      case with_draw([{block, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "block with padding" do
      block = %Block{
        borders: [:all],
        padding: {1, 1, 1, 1}
      }

      rect = %Rect{x: 0, y: 0, width: 20, height: 5}

      case with_draw([{block, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "Paragraph with block" do
    test "paragraph inside a block" do
      paragraph = %Paragraph{
        text: "Inside a box",
        style: %Style{fg: :cyan},
        block: %Block{
          title: "Title",
          borders: [:all],
          border_type: :rounded,
          border_style: %Style{fg: :yellow}
        }
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      case with_draw([{paragraph, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "List widget" do
    test "simple list" do
      list = %List{
        items: ["Alpha", "Beta", "Gamma"],
        style: %Style{fg: :white}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 10}

      case with_draw([{list, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "list with selection" do
      list = %List{
        items: ["One", "Two", "Three"],
        highlight_style: %Style{fg: :yellow, modifiers: [:bold]},
        highlight_symbol: ">> ",
        selected: 1
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 10}

      case with_draw([{list, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "list with block" do
      list = %List{
        items: ["Item A", "Item B"],
        block: %Block{title: "My List", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 10}

      case with_draw([{list, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "Table widget" do
    test "simple table" do
      table = %Table{
        rows: [["Alice", "30"], ["Bob", "25"]],
        widths: [{:length, 15}, {:length, 10}]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      case with_draw([{table, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "table with header" do
      table = %Table{
        rows: [["Alice", "30"], ["Bob", "25"]],
        header: ["Name", "Age"],
        widths: [{:length, 15}, {:length, 10}]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      case with_draw([{table, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "table with selection and block" do
      table = %Table{
        rows: [["Row 1"], ["Row 2"], ["Row 3"]],
        widths: [{:percentage, 100}],
        highlight_style: %Style{fg: :cyan},
        highlight_symbol: "> ",
        selected: 0,
        block: %Block{title: "Data", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      case with_draw([{table, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "table with percentage widths" do
      table = %Table{
        rows: [["A", "B", "C"]],
        widths: [{:percentage, 33}, {:percentage, 33}, {:percentage, 34}]
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 5}

      case with_draw([{table, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "Gauge widget" do
    test "basic gauge" do
      gauge = %Gauge{
        ratio: 0.5,
        gauge_style: %Style{fg: :green}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 1}

      case with_draw([{gauge, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "gauge with label and block" do
      gauge = %Gauge{
        ratio: 0.75,
        label: "75%",
        gauge_style: %Style{fg: :blue},
        block: %Block{title: "Progress", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      case with_draw([{gauge, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "gauge with zero ratio" do
      gauge = %Gauge{ratio: 0.0}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      case with_draw([{gauge, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end

    test "gauge with integer ratio coerced to float" do
      gauge = %Gauge{ratio: 1}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      case with_draw([{gauge, rect}]) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "mixed widgets in one frame" do
    test "multiple widget types in a single draw call" do
      widgets = [
        {%Paragraph{text: "Header"}, %Rect{x: 0, y: 0, width: 40, height: 3}},
        {%List{items: ["a", "b"]}, %Rect{x: 0, y: 3, width: 40, height: 5}},
        {%Gauge{ratio: 0.5}, %Rect{x: 0, y: 8, width: 40, height: 1}}
      ]

      case with_draw(widgets) do
        {:drew, result} -> assert :ok = result
        :no_tty -> :ok
      end
    end
  end

  describe "encoding validation (no terminal needed)" do
    test "block struct has correct defaults" do
      block = %Block{}
      assert block.title == nil
      assert block.borders == []
      assert block.border_type == :plain
      assert block.padding == {0, 0, 0, 0}
    end

    test "list struct has correct defaults" do
      list = %List{}
      assert list.items == []
      assert list.selected == nil
      assert list.highlight_symbol == nil
    end

    test "table struct has correct defaults" do
      table = %Table{}
      assert table.rows == []
      assert table.header == nil
      assert table.widths == []
      assert table.column_spacing == 1
    end

    test "gauge struct has correct defaults" do
      gauge = %Gauge{}
      assert gauge.ratio == 0.0
      assert gauge.label == nil
    end
  end
end
