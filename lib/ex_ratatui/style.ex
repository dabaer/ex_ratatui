defmodule ExRatatui.Style do
  @moduledoc """
  Style configuration for widgets.

  ## Fields

    * `:fg` - foreground color (see Colors below), or `nil` for terminal default
    * `:bg` - background color, or `nil` for terminal default
    * `:modifiers` - list of text modifiers (see Modifiers below)

  ## Colors

  Named colors (atoms):

  | Standard | Light variant |
  |----------|---------------|
  | `:black` | `:dark_gray` |
  | `:red` | `:light_red` |
  | `:green` | `:light_green` |
  | `:yellow` | `:light_yellow` |
  | `:blue` | `:light_blue` |
  | `:magenta` | `:light_magenta` |
  | `:cyan` | `:light_cyan` |
  | `:gray` | `:white` |

  Special: `:reset` resets to terminal default.

  RGB and indexed colors:

      # 24-bit RGB
      %Style{fg: {:rgb, 255, 100, 0}}

      # 256-color indexed (0-255)
      %Style{fg: {:indexed, 42}}

  ## Modifiers

  Text modifiers: `:bold`, `:dim`, `:italic`, `:underlined`, `:crossed_out`, `:reversed`

      %Style{fg: :green, modifiers: [:bold, :italic]}

  ## Examples

      iex> %ExRatatui.Style{fg: :red, bg: :black, modifiers: [:bold]}
      %ExRatatui.Style{fg: :red, bg: :black, modifiers: [:bold]}

      iex> %ExRatatui.Style{fg: {:rgb, 255, 100, 0}}
      %ExRatatui.Style{fg: {:rgb, 255, 100, 0}, bg: nil, modifiers: []}

      iex> %ExRatatui.Style{}
      %ExRatatui.Style{fg: nil, bg: nil, modifiers: []}
  """

  defstruct fg: nil, bg: nil, modifiers: []

  @type color ::
          :black
          | :red
          | :green
          | :yellow
          | :blue
          | :magenta
          | :cyan
          | :gray
          | :dark_gray
          | :light_red
          | :light_green
          | :light_yellow
          | :light_blue
          | :light_magenta
          | :light_cyan
          | :white
          | :reset
          | {:rgb, 0..255, 0..255, 0..255}
          | {:indexed, 0..255}

  @type modifier :: :bold | :dim | :italic | :underlined | :crossed_out | :reversed

  @type t :: %__MODULE__{
          fg: color() | nil,
          bg: color() | nil,
          modifiers: [modifier()]
        }
end
