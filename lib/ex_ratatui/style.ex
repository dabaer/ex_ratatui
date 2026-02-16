defmodule ExRatatui.Style do
  @moduledoc """
  Style configuration for widgets.

  Colors can be atoms (`:red`, `:green`, `:blue`, etc.),
  RGB tuples (`{:rgb, 255, 100, 0}`), or indexed (`{:indexed, 42}`).
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
