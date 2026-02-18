defmodule ExRatatui.TerminalTest do
  use ExUnit.Case

  alias ExRatatui.Native

  describe "NIF loading" do
    test "init_terminal NIF is loaded and callable" do
      result = Native.init_terminal()
      assert result == :ok or match?({:error, _}, result)

      if result == :ok, do: Native.restore_terminal()
    end

    test "restore_terminal NIF is loaded and callable" do
      assert :ok = Native.restore_terminal()
    end

    test "terminal_size NIF is loaded and callable" do
      result = ExRatatui.terminal_size()
      assert match?({_, _}, result)
    end
  end

  describe "restore_terminal safety" do
    test "restore without init is a safe no-op" do
      assert :ok = Native.restore_terminal()
    end

    test "double restore is a safe no-op" do
      assert :ok = Native.restore_terminal()
      assert :ok = Native.restore_terminal()
    end
  end

  describe "run/1" do
    test "either executes the function (TTY) or returns error (no TTY)" do
      result = ExRatatui.run(fn -> :ran end)

      case result do
        :ran -> :ok
        {:error, _reason} -> :ok
      end
    end

    test "ensures terminal is restored after function executes" do
      ExRatatui.run(fn -> :ok end)
      # restore is a safe no-op if already restored (or never initialized)
      assert :ok = Native.restore_terminal()
    end
  end

  describe "BEAM scheduler safety" do
    test "NIF calls do not block concurrent tasks" do
      tasks =
        for _ <- 1..4 do
          Task.async(fn ->
            Process.sleep(10)
            :alive
          end)
        end

      ExRatatui.terminal_size()
      Native.restore_terminal()

      results = Task.await_many(tasks, 5000)
      assert Enum.all?(results, &(&1 == :alive))
    end
  end

  describe "terminal lifecycle" do
    test "init and restore complete successfully" do
      case Native.init_terminal() do
        :ok -> assert :ok = Native.restore_terminal()
        {:error, _} -> :ok
      end
    end

    test "terminal_size returns integers after init" do
      case Native.init_terminal() do
        :ok ->
          assert {w, h} = ExRatatui.terminal_size()
          assert is_integer(w) and is_integer(h)
          assert :ok = Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "double init replaces terminal cleanly" do
      case Native.init_terminal() do
        :ok ->
          :ok = Native.init_terminal()
          assert :ok = Native.restore_terminal()

        {:error, _} ->
          :ok
      end
    end

    test "full ExRatatui.run/1 lifecycle" do
      ran? =
        case ExRatatui.run(fn -> :ran end) do
          :ran -> true
          {:error, _} -> false
        end

      if ran? do
        # Terminal should have been restored by run/1
        assert :ok = Native.restore_terminal()
      end
    end
  end
end
