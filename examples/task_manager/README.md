# Task Manager — ExRatatui + Ecto Demo

A terminal task manager built with [ExRatatui](https://github.com/mcass19/ex_ratatui) and [Ecto](https://github.com/elixir-ecto/ecto) + SQLite. Demonstrates how to build a supervised, database-backed TUI application using the `ExRatatui.App` behaviour.

## What This Shows

- `ExRatatui.App` behaviour with `mount/1`, `render/2`, `handle_event/2` callbacks
- OTP supervision: Repo and TUI run side-by-side under a supervisor
- Ecto + SQLite for persistent task storage
- Full CRUD operations from the terminal
- Layout with Table, Gauge, and Paragraph widgets

## Setup

```bash
cd examples/task_manager
mix deps.get
mix ecto.setup
```

## Run

```bash
mix run --no-halt
```

`--no-halt` keeps the BEAM VM alive after starting the application. Without it, the VM would exit immediately after booting the supervision tree, killing the TUI process.

Data is stored in a local SQLite file at `task_manager_dev.db` (or `task_manager_test.db` for tests).

## Controls

| Key | Action |
|-----|--------|
| `j` / `Down` | Move selection down |
| `k` / `Up` | Move selection up |
| `Enter` | Toggle task status (Todo -> In Progress -> Done) |
| `p` | Cycle priority (High -> Med -> Low) |
| `n` | Create new task (type name, Enter to confirm) |
| `d` | Delete selected task |
| `f` | Cycle filter (All / Todo / In Progress / Done) |
| `Esc` | Cancel input |
| `q` | Quit |

## Project Structure

```
lib/
  task_manager.ex              # Context: CRUD operations
  task_manager/
    application.ex             # Supervisor: Repo + TUI
    repo.ex                    # Ecto Repo (SQLite)
    task.ex                    # Ecto schema + changeset
    tui.ex                     # ExRatatui.App TUI interface
```

## How It Works

`TaskManager.TUI` implements the `ExRatatui.App` behaviour, which wraps a GenServer managing the terminal lifecycle:

```elixir
defmodule TaskManager.TUI do
  use ExRatatui.App

  def mount(_opts) do
    tasks = TaskManager.list_tasks(:all)
    {:ok, %{tasks: tasks, selected: 0, filter: :all}}
  end

  def render(state, frame) do
    # Build layout, return [{widget, rect}] list
  end

  def handle_event(%Event.Key{code: "enter"}, state) do
    {:ok, _} = TaskManager.toggle_status(selected_task)
    {:noreply, refresh_tasks(state)}
  end
end
```

The supervision tree starts the Repo and TUI together:

```elixir
children = [
  TaskManager.Repo,
  {TaskManager.TUI, []}
]
```

Tasks persist to a local SQLite database. Create, toggle, delete, and filter — all from the terminal.

## Tests

```bash
mix test
```

The context module has full test coverage. The TUI is disabled during tests via config.
