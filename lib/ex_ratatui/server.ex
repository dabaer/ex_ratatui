defmodule ExRatatui.Server do
  @moduledoc false

  use GenServer

  require Logger

  alias ExRatatui.Frame
  alias ExRatatui.Native

  defstruct [:mod, :user_state, poll_interval: 16, terminal_initialized: false]

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  ## GenServer callbacks

  @impl true
  def init(opts) do
    mod = Keyword.fetch!(opts, :mod)
    poll_interval = Keyword.get(opts, :poll_interval, 16)
    test_mode = Keyword.get(opts, :test_mode)

    Process.flag(:trap_exit, true)

    case init_terminal(test_mode) do
      :ok ->
        case mod.mount(opts) do
          {:ok, user_state} ->
            state = %__MODULE__{
              mod: mod,
              user_state: user_state,
              poll_interval: poll_interval,
              terminal_initialized: true
            }

            state = do_render(state)
            schedule_poll(state)

            {:ok, state}

          {:error, reason} ->
            restore_terminal()
            {:stop, reason}
        end

      {:error, reason} ->
        {:stop, {:terminal_init_failed, reason}}
    end
  end

  @impl true
  def handle_info(:poll, state) do
    result =
      case ExRatatui.poll_event(0) do
        nil ->
          {:continue, state}

        {:error, _} ->
          {:continue, state}

        event ->
          dispatch_event(state, event)
      end

    case result do
      {:stop, state} ->
        {:stop, :normal, state}

      {:continue, state} ->
        state = do_render(state)
        schedule_poll(state)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(msg, state) do
    case state.mod.handle_info(msg, state.user_state) do
      {:noreply, new_user_state} ->
        state = %{state | user_state: new_user_state}
        state = do_render(state)
        {:noreply, state}

      {:stop, new_user_state} ->
        {:stop, :normal, %{state | user_state: new_user_state}}
    end
  end

  @impl true
  def terminate(_reason, %__MODULE__{terminal_initialized: true}) do
    restore_terminal()
    :ok
  end

  def terminate(_reason, _state), do: :ok

  ## Private helpers

  defp init_terminal(nil), do: Native.init_terminal()
  defp init_terminal({width, height}), do: ExRatatui.init_test_terminal(width, height)

  defp restore_terminal do
    Native.restore_terminal()
  rescue
    e ->
      Logger.warning("Failed to restore terminal: #{Exception.message(e)}")
      :ok
  end

  defp schedule_poll(state) do
    Process.send_after(self(), :poll, state.poll_interval)
  end

  defp dispatch_event(state, event) do
    case state.mod.handle_event(event, state.user_state) do
      {:noreply, new_user_state} ->
        {:continue, %{state | user_state: new_user_state}}

      {:stop, new_user_state} ->
        {:stop, %{state | user_state: new_user_state}}
    end
  end

  defp do_render(state) do
    {w, h} =
      case ExRatatui.terminal_size() do
        {w, h} when is_integer(w) and is_integer(h) -> {w, h}
        {:error, _} -> {80, 24}
      end

    frame = %Frame{width: w, height: h}

    widgets = state.mod.render(state.user_state, frame)
    draw_widgets(widgets)
    state
  rescue
    e ->
      Logger.error("ExRatatui render error: #{Exception.message(e)}")
      state
  end

  defp draw_widgets([]), do: :ok

  defp draw_widgets(widgets) do
    case ExRatatui.draw(widgets) do
      :ok -> :ok
      {:error, reason} -> Logger.error("ExRatatui draw error: #{inspect(reason)}")
    end
  end
end
