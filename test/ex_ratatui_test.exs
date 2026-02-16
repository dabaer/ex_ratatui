defmodule ExRatatuiTest do
  use ExUnit.Case

  test "widget structs can be created" do
    paragraph = %ExRatatui.Widgets.Paragraph{text: "Hello"}
    assert paragraph.text == "Hello"

    block = %ExRatatui.Widgets.Block{title: "Test", borders: [:all]}
    assert block.title == "Test"

    list = %ExRatatui.Widgets.List{items: ["a", "b", "c"]}
    assert length(list.items) == 3

    table = %ExRatatui.Widgets.Table{rows: [["a", "b"]], header: ["Col1", "Col2"]}
    assert length(table.rows) == 1

    gauge = %ExRatatui.Widgets.Gauge{ratio: 0.5, label: "50%"}
    assert gauge.ratio == 0.5
  end

  test "style struct has defaults" do
    style = %ExRatatui.Style{}
    assert style.fg == nil
    assert style.bg == nil
    assert style.modifiers == []
  end

  test "rect struct has defaults" do
    rect = %ExRatatui.Layout.Rect{}
    assert rect.x == 0
    assert rect.y == 0
    assert rect.width == 0
    assert rect.height == 0
  end

  test "event structs can be created" do
    key = %ExRatatui.Event.Key{code: "q", modifiers: [], kind: "press"}
    assert key.code == "q"

    mouse = %ExRatatui.Event.Mouse{kind: "down", button: "left", x: 10, y: 20}
    assert mouse.x == 10

    resize = %ExRatatui.Event.Resize{width: 80, height: 24}
    assert resize.width == 80
  end

  test "event from_raw parses key events" do
    raw = %{"type" => "key", "code" => "q", "modifiers" => [], "kind" => "press"}
    event = ExRatatui.Event.from_raw(raw)
    assert %ExRatatui.Event.Key{code: "q"} = event
  end

  test "event from_raw parses resize events" do
    raw = %{"type" => "resize", "width" => 120, "height" => 40}
    event = ExRatatui.Event.from_raw(raw)
    assert %ExRatatui.Event.Resize{width: 120, height: 40} = event
  end

  test "event from_raw returns nil for unknown events" do
    assert ExRatatui.Event.from_raw(%{"type" => "unknown"}) == nil
  end
end
