# Example: dashboard using all widgets — Paragraph, Block, List, Table, Gauge.
# Run with: mix run examples/dashboard.exs
#
# Controls: Tab = cycle focus, Up/k = up, Down/j = down, q = quit

alias ExRatatui.Layout
alias ExRatatui.Layout.Rect
alias ExRatatui.Style
alias ExRatatui.Widgets.{Block, Gauge, List, Paragraph, Table}
alias ExRatatui.Event

defmodule Dashboard do
  @tasks [
    ["EX-101", "Implement login", "Done"],
    ["EX-102", "Add search API", "In Progress"],
    ["EX-103", "Fix N+1 query", "In Progress"],
    ["EX-104", "Write tests", "Todo"],
    ["EX-105", "Update docs", "Todo"],
    ["EX-106", "Deploy v0.2", "Todo"]
  ]

  @team ["Alice", "Bob", "Carol", "Dave", "Eve"]

  @panels [:team, :tasks]

  def run do
    ExRatatui.run(fn ->
      loop(%{
        focus: :team,
        team_selected: 0,
        task_selected: 0,
        tick: 0
      })
    end)
  end

  defp loop(state) do
    {w, h} = ExRatatui.terminal_size()
    area = %Rect{x: 0, y: 0, width: w, height: h}

    # Main layout: header, body, footer
    [header_area, body_area, footer_area] =
      Layout.split(area, :vertical, [{:length, 3}, {:min, 0}, {:length, 3}])

    # Body: sidebar (team list) | main (task table)
    [sidebar_area, main_area] =
      Layout.split(body_area, :horizontal, [{:percentage, 30}, {:percentage, 70}])

    # Footer: gauge + status
    [gauge_area, status_area] =
      Layout.split(footer_area, :vertical, [{:length, 1}, {:length, 2}])

    widgets = [
      {header_widget(), header_area},
      {team_widget(state), sidebar_area},
      {tasks_widget(state), main_area},
      {gauge_widget(state), gauge_area},
      {status_widget(state), status_area}
    ]

    ExRatatui.draw(widgets)

    case ExRatatui.poll_event(100) do
      %Event.Key{code: "q", kind: "press"} ->
        :ok

      %Event.Key{code: "tab", kind: "press"} ->
        next_focus = next_panel(state.focus)
        loop(%{state | focus: next_focus, tick: state.tick + 1})

      %Event.Key{code: code, kind: "press"} when code in ["up", "k"] ->
        loop(move_selection(state, -1))

      %Event.Key{code: code, kind: "press"} when code in ["down", "j"] ->
        loop(move_selection(state, 1))

      _ ->
        loop(%{state | tick: state.tick + 1})
    end
  end

  defp header_widget do
    %Paragraph{
      text: "  ExRatatui Dashboard — All Widgets Demo",
      style: %Style{fg: :cyan, modifiers: [:bold]},
      block: %Block{
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: :dark_gray}
      }
    }
  end

  defp team_widget(state) do
    focused = state.focus == :team

    %List{
      items: @team,
      highlight_style: %Style{
        fg: if(focused, do: :yellow, else: :dark_gray),
        modifiers: if(focused, do: [:bold], else: [])
      },
      highlight_symbol: if(focused, do: " ▸ ", else: "   "),
      selected: state.team_selected,
      block: %Block{
        title: " Team #{if(focused, do: "●", else: "○")} ",
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: if(focused, do: :cyan, else: :dark_gray)}
      }
    }
  end

  defp tasks_widget(state) do
    focused = state.focus == :tasks

    %Table{
      rows: @tasks,
      header: ["ID", "Task", "Status"],
      widths: [{:length, 8}, {:min, 10}, {:length, 12}],
      highlight_style: %Style{
        fg: if(focused, do: :yellow, else: :dark_gray),
        modifiers: if(focused, do: [:bold], else: [])
      },
      highlight_symbol: if(focused, do: " ▸ ", else: "   "),
      selected: state.task_selected,
      column_spacing: 2,
      block: %Block{
        title: " Tasks #{if(focused, do: "●", else: "○")} ",
        borders: [:all],
        border_type: :rounded,
        border_style: %Style{fg: if(focused, do: :cyan, else: :dark_gray)}
      }
    }
  end

  defp gauge_widget(state) do
    done = Enum.count(@tasks, fn [_, _, s] -> s == "Done" end)
    total = length(@tasks)
    ratio = done / total

    %Gauge{
      ratio: ratio,
      label: "Progress: #{done}/#{total} tasks done",
      gauge_style: %Style{fg: :green},
      style: %Style{fg: :white}
    }
  end

  defp status_widget(state) do
    panel_name = state.focus |> Atom.to_string() |> String.capitalize()

    %Paragraph{
      text: " Tab: switch panel │ ↑/k ↓/j: navigate │ q: quit │ Focus: #{panel_name}",
      style: %Style{fg: :dark_gray},
      block: %Block{
        borders: [:top],
        border_style: %Style{fg: :dark_gray}
      }
    }
  end

  defp next_panel(current) do
    idx = Enum.find_index(@panels, &(&1 == current))
    Enum.at(@panels, rem(idx + 1, length(@panels)))
  end

  defp move_selection(state, delta) do
    case state.focus do
      :team ->
        new = (state.team_selected + delta) |> max(0) |> min(length(@team) - 1)
        %{state | team_selected: new, tick: state.tick + 1}

      :tasks ->
        new = (state.task_selected + delta) |> max(0) |> min(length(@tasks) - 1)
        %{state | task_selected: new, tick: state.tick + 1}
    end
  end
end

Dashboard.run()
