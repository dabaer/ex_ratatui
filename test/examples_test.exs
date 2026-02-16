defmodule ExRatatui.ExamplesTest do
  use ExUnit.Case, async: true

  @examples_dir Path.expand("../examples", __DIR__)

  for path <- Path.wildcard(Path.expand("../examples/*.exs", __DIR__)) do
    name = Path.basename(path, ".exs")

    test "#{name}.exs parses and compiles" do
      path = Path.join(@examples_dir, unquote(name) <> ".exs")
      code = File.read!(path)

      assert {:ok, _ast} = Code.string_to_quoted(code, file: path)
    end
  end
end
