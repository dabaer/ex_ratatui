defmodule TaskManager.TUI do
  @moduledoc """
  Terminal UI for the Task Manager demo app.

  Uses `ExRatatui.App` to render a full CRUD interface backed by Ecto/SQLite.

  ## Layout

      +-------------------------------------------+
      | Task Manager - Filter: All [3 tasks]      |  header
      +-------------------------------------------+
      | # | Title           | Status  | Priority  |  body (table)
      | 1 | Buy groceries   | Done    | ***       |
      | 2 | Write tests     | WIP     | **        |
      +-------------------------------------------+
      | ============ 33% done                     |  gauge
      | j/k:nav Enter:toggle n:new d:del f:filter |  footer
      +-------------------------------------------+

  ## Key Bindings

  Normal mode:
    - `q` quit
    - `j`/Down move selection down
    - `k`/Up move selection up
    - Enter toggle task status
    - `n` new task
    - `d` delete selected task
    - `f` cycle filter

  Input mode:
    - Enter confirm new task
    - Esc cancel
    - Backspace delete char
    - Any printable char append to input buffer
  """

  use ExRatatui.App

  alias ExRatatui.Layout
  alias ExRatatui.Layout.Rect
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Gauge, Paragraph, Table}

  # ── Callbacks ──────────────────────────────────────────────────

  @impl true
  def mount(_opts) do
    tasks = TaskManager.list_tasks(:all)
    {total, done} = TaskManager.completion_stats()

    {:ok,
     %{
       tasks: tasks,
       selected: 0,
       filter: :all,
       input_mode: nil,
       input_buffer: "",
       total: total,
       done: done
     }}
  end

  @impl true
  def render(state, frame) do
    area = %Rect{x: 0, y: 0, width: frame.width, height: frame.height}

    [header_area, body_area, gauge_area, footer_area] =
      Layout.split(area, :vertical, [
        {:length, 3},
        {:min, 0},
        {:length, 1},
        {:length, 3}
      ])

    [
      {header_widget(state), header_area},
      {body_widget(state), body_area},
      {gauge_widget(state), gauge_area},
      {footer_widget(state), footer_area}
    ]
  end

  @impl true
  def handle_event(
        %ExRatatui.Event.Key{code: code, kind: "press"},
        %{input_mode: :new_task} = state
      ) do
    handle_input_mode(code, state)
  end

  def handle_event(%ExRatatui.Event.Key{code: "q", kind: "press"}, %{input_mode: nil} = state) do
    {:stop, state}
  end

  def handle_event(%ExRatatui.Event.Key{code: code, kind: "press"}, %{input_mode: nil} = state)
      when code in ["j", "down"] do
    max_idx = max(length(state.tasks) - 1, 0)
    new_selected = min(state.selected + 1, max_idx)
    {:noreply, %{state | selected: new_selected}}
  end

  def handle_event(%ExRatatui.Event.Key{code: code, kind: "press"}, %{input_mode: nil} = state)
      when code in ["k", "up"] do
    new_selected = max(state.selected - 1, 0)
    {:noreply, %{state | selected: new_selected}}
  end

  def handle_event(%ExRatatui.Event.Key{code: "enter", kind: "press"}, %{input_mode: nil} = state) do
    state = toggle_selected_task(state)
    {:noreply, state}
  end

  def handle_event(%ExRatatui.Event.Key{code: "n", kind: "press"}, %{input_mode: nil} = state) do
    {:noreply, %{state | input_mode: :new_task, input_buffer: ""}}
  end

  def handle_event(%ExRatatui.Event.Key{code: "d", kind: "press"}, %{input_mode: nil} = state) do
    state = delete_selected_task(state)
    {:noreply, state}
  end

  def handle_event(%ExRatatui.Event.Key{code: "f", kind: "press"}, %{input_mode: nil} = state) do
    next_filter = cycle_filter(state.filter)
    state = %{state | filter: next_filter}
    {:noreply, refresh_tasks(state)}
  end

  def handle_event(_event, state) do
    {:noreply, state}
  end

  # ── Input Mode Handling ────────────────────────────────────────

  defp handle_input_mode("enter", state) do
    title = String.trim(state.input_buffer)

    state =
      if title == "" do
        %{state | input_mode: nil, input_buffer: ""}
      else
        TaskManager.create_task(%{title: title})
        state = refresh_tasks(%{state | input_mode: nil, input_buffer: ""})
        # Select the newly created task (last one in the list)
        %{state | selected: max(length(state.tasks) - 1, 0)}
      end

    {:noreply, state}
  end

  defp handle_input_mode("esc", state) do
    {:noreply, %{state | input_mode: nil, input_buffer: ""}}
  end

  defp handle_input_mode("backspace", state) do
    buf = String.slice(state.input_buffer, 0..-2//1)
    {:noreply, %{state | input_buffer: buf}}
  end

  defp handle_input_mode(char, state) when byte_size(char) == 1 do
    {:noreply, %{state | input_buffer: state.input_buffer <> char}}
  end

  defp handle_input_mode(_code, state) do
    {:noreply, state}
  end

  # ── Widgets ────────────────────────────────────────────────────

  defp header_widget(state) do
    filter_label = filter_display(state.filter)
    task_count = length(state.tasks)

    %Paragraph{
      text: "  Task Manager \u2014 Filter: #{filter_label} [#{task_count} tasks]",
      style: %Style{fg: :cyan, modifiers: [:bold]},
      block: %Block{
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :dark_gray}
      }
    }
  end

  defp body_widget(state) do
    rows =
      state.tasks
      |> Enum.with_index(1)
      |> Enum.map(fn {task, idx} ->
        [
          Integer.to_string(idx),
          task.title,
          status_display(task.status),
          priority_display(task.priority)
        ]
      end)

    title =
      if state.input_mode == :new_task do
        " New task: #{state.input_buffer}\u2588 "
      else
        " Tasks "
      end

    selected =
      if length(state.tasks) > 0 do
        state.selected
      else
        nil
      end

    %Table{
      rows: rows,
      header: ["#", "Title", "Status", "Priority"],
      widths: [{:length, 4}, {:min, 10}, {:length, 16}, {:length, 10}],
      highlight_style: %Style{fg: :yellow, modifiers: [:bold]},
      highlight_symbol: " \u25B8 ",
      selected: selected,
      column_spacing: 1,
      block: %Block{
        title: title,
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :cyan}
      }
    }
  end

  defp gauge_widget(state) do
    ratio =
      if state.total > 0 do
        state.done / state.total
      else
        0.0
      end

    %Gauge{
      ratio: ratio,
      label: "#{state.done}/#{state.total} tasks done",
      gauge_style: %Style{fg: :green},
      style: %Style{fg: :white}
    }
  end

  defp footer_widget(state) do
    text =
      if state.input_mode == :new_task do
        "  Type task name, Enter to confirm, Esc to cancel"
      else
        "  j/\u2193 k/\u2191 Enter:toggle  n:new  d:del  f:filter  q:quit"
      end

    %Paragraph{
      text: text,
      style: %Style{fg: :dark_gray},
      block: %Block{
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :dark_gray}
      }
    }
  end

  # ── Helpers ────────────────────────────────────────────────────

  defp refresh_tasks(state) do
    tasks = TaskManager.list_tasks(state.filter)
    {total, done} = TaskManager.completion_stats()
    selected = min(state.selected, max(length(tasks) - 1, 0))
    %{state | tasks: tasks, selected: selected, total: total, done: done}
  end

  defp toggle_selected_task(state) do
    task = Enum.at(state.tasks, state.selected)

    if task do
      TaskManager.toggle_status(task)
      refresh_tasks(state)
    else
      state
    end
  end

  defp delete_selected_task(state) do
    task = Enum.at(state.tasks, state.selected)

    if task do
      TaskManager.delete_task(task)
      refresh_tasks(state)
    else
      state
    end
  end

  defp cycle_filter(:all), do: :todo
  defp cycle_filter(:todo), do: :in_progress
  defp cycle_filter(:in_progress), do: :done
  defp cycle_filter(:done), do: :all

  defp filter_display(:all), do: "All"
  defp filter_display(:todo), do: "Todo"
  defp filter_display(:in_progress), do: "In Progress"
  defp filter_display(:done), do: "Done"

  defp status_display("done"), do: "\u2713 Done"
  defp status_display("in_progress"), do: "\u25D0 In Progress"
  defp status_display("todo"), do: "\u25CB Todo"
  defp status_display(other), do: "? #{other}"

  defp priority_display(1), do: "\u2605\u2605\u2605"
  defp priority_display(2), do: "\u2605\u2605"
  defp priority_display(3), do: "\u2605"
  defp priority_display(_), do: "\u2605\u2605"
end
