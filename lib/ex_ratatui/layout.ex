defmodule ExRatatui.Layout do
  @moduledoc """
  Layout system for splitting areas into sub-regions.

  Uses ratatui's constraint-based layout engine to divide a `Rect` into
  multiple sub-regions along a direction.

  ## Constraints

    * `{:percentage, n}` - percentage of the total space
    * `{:length, n}` - exact number of cells
    * `{:min, n}` - minimum number of cells
    * `{:max, n}` - maximum number of cells
    * `{:ratio, numerator, denominator}` - fractional ratio

  ## Example

      area = %Rect{x: 0, y: 0, width: 80, height: 24}

      [header, body, footer] = Layout.split(area, :vertical, [
        {:length, 3},
        {:min, 0},
        {:length, 1}
      ])

      [sidebar, main] = Layout.split(body, :horizontal, [
        {:percentage, 30},
        {:percentage, 70}
      ])
  """

  defmodule Rect do
    @moduledoc """
    A rectangular area on the terminal screen.

    ## Fields

      * `:x` - left column (0-based)
      * `:y` - top row (0-based)
      * `:width` - width in cells
      * `:height` - height in cells
    """
    defstruct x: 0, y: 0, width: 0, height: 0
  end

  @type direction :: :horizontal | :vertical
  @type constraint ::
          {:percentage, non_neg_integer()}
          | {:length, non_neg_integer()}
          | {:min, non_neg_integer()}
          | {:max, non_neg_integer()}
          | {:ratio, non_neg_integer(), non_neg_integer()}

  @doc """
  Splits a `Rect` into sub-regions based on direction and constraints.

      [top, bottom] = ExRatatui.Layout.split(area, :vertical, [
        {:percentage, 50},
        {:percentage, 50}
      ])
  """
  def split(%Rect{} = area, direction, constraints)
      when direction in [:horizontal, :vertical] and is_list(constraints) do
    rect_map = %{"x" => area.x, "y" => area.y, "width" => area.width, "height" => area.height}

    case ExRatatui.Native.layout_split(
           rect_map,
           Atom.to_string(direction),
           Enum.map(constraints, &encode_constraint/1)
         ) do
      rects when is_list(rects) ->
        Enum.map(rects, fn {x, y, width, height} ->
          %Rect{x: x, y: y, width: width, height: height}
        end)

      {:error, _} = err ->
        err
    end
  end

  defp encode_constraint({:percentage, n}), do: %{"type" => "percentage", "value" => n}
  defp encode_constraint({:length, n}), do: %{"type" => "length", "value" => n}
  defp encode_constraint({:min, n}), do: %{"type" => "min", "value" => n}
  defp encode_constraint({:max, n}), do: %{"type" => "max", "value" => n}
  defp encode_constraint({:ratio, num, den}), do: %{"type" => "ratio", "num" => num, "den" => den}
end
