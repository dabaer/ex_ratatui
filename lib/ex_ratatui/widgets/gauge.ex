defmodule ExRatatui.Widgets.Gauge do
  @moduledoc """
  A progress bar widget.

  ## Fields

    * `:ratio` - progress value from `0.0` to `1.0` (clamped automatically)
    * `:label` - optional label string displayed on the gauge
    * `:style` - `%ExRatatui.Style{}` for the widget background
    * `:block` - optional `%ExRatatui.Widgets.Block{}` container
    * `:gauge_style` - `%ExRatatui.Style{}` for the filled portion

  ## Examples

      iex> %ExRatatui.Widgets.Gauge{ratio: 0.75, label: "75%"}
      %ExRatatui.Widgets.Gauge{
        ratio: 0.75,
        label: "75%",
        style: %ExRatatui.Style{},
        block: nil,
        gauge_style: %ExRatatui.Style{}
      }
  """

  @type t :: %__MODULE__{
          ratio: float(),
          label: String.t() | nil,
          style: ExRatatui.Style.t(),
          block: ExRatatui.Widgets.Block.t() | nil,
          gauge_style: ExRatatui.Style.t()
        }

  defstruct ratio: 0.0,
            label: nil,
            style: %ExRatatui.Style{},
            block: nil,
            gauge_style: %ExRatatui.Style{}
end
