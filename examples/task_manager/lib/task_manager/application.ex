defmodule TaskManager.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children =
      [TaskManager.Repo] ++ tui_children()

    opts = [strategy: :one_for_one, name: TaskManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp tui_children do
    if Application.get_env(:task_manager, :start_tui, true) do
      [{TaskManager.TUI, []}]
    else
      []
    end
  end
end
