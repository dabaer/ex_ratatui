defmodule ExRatatui.EventTest do
  use ExUnit.Case

  describe "poll_event/1" do
    test "returns nil (timeout) or {:error, _} (no TTY)" do
      result = ExRatatui.poll_event(10)
      assert result == nil or match?({:error, _}, result)
    end

    test "does not block the BEAM (runs on dirty scheduler)" do
      parent = self()

      task =
        Task.async(fn ->
          send(parent, :alive)
          :done
        end)

      # poll_event is a DirtyIo NIF — must not block the task
      assert_receive :alive, 1000
      ExRatatui.poll_event(50)
      assert Task.await(task) == :done
    end

    test "concurrent poll_event calls do not deadlock" do
      tasks =
        for _ <- 1..4 do
          Task.async(fn ->
            result = ExRatatui.poll_event(10)
            assert result == nil or match?({:error, _}, result)
            :ok
          end)
        end

      results = Task.await_many(tasks, 5000)
      assert Enum.all?(results, &(&1 == :ok))
    end
  end
end
