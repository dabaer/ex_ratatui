use ratatui::style::{Color, Modifier, Style};
use rustler::{Error, Term};
use std::collections::HashMap;

/// Decode an Elixir style map into a ratatui Style.
///
/// Expects a string-keyed map with optional "fg", "bg", and "modifiers" keys.
pub fn decode_style(term: Term) -> Result<Style, Error> {
    let map: HashMap<String, Term> = term.decode()?;
    let mut style = Style::default();

    if let Some(fg_term) = map.get("fg") {
        style = style.fg(decode_color(*fg_term)?);
    }

    if let Some(bg_term) = map.get("bg") {
        style = style.bg(decode_color(*bg_term)?);
    }

    if let Some(mods_term) = map.get("modifiers") {
        let mod_names: Vec<String> = mods_term.decode()?;
        for name in &mod_names {
            style = style.add_modifier(parse_modifier(name)?);
        }
    }

    Ok(style)
}

pub fn decode_color(term: Term) -> Result<Color, Error> {
    // Try as a string (named color)
    if let Ok(name) = term.decode::<String>() {
        return parse_named_color(&name);
    }

    // Try as a map (rgb or indexed)
    if let Ok(map) = term.decode::<HashMap<String, Term>>() {
        let color_type: String = map
            .get("type")
            .ok_or_else(|| Error::Term(Box::new("color map missing 'type'")))?
            .decode()?;

        return match color_type.as_str() {
            "rgb" => {
                let r: u8 = map
                    .get("r")
                    .ok_or_else(|| Error::Term(Box::new("rgb missing 'r'")))?
                    .decode()?;
                let g: u8 = map
                    .get("g")
                    .ok_or_else(|| Error::Term(Box::new("rgb missing 'g'")))?
                    .decode()?;
                let b: u8 = map
                    .get("b")
                    .ok_or_else(|| Error::Term(Box::new("rgb missing 'b'")))?
                    .decode()?;
                Ok(Color::Rgb(r, g, b))
            }
            "indexed" => {
                let i: u8 = map
                    .get("value")
                    .ok_or_else(|| Error::Term(Box::new("indexed missing 'value'")))?
                    .decode()?;
                Ok(Color::Indexed(i))
            }
            other => Err(Error::Term(Box::new(format!(
                "unknown color type: {other}"
            )))),
        };
    }

    Err(Error::Term(Box::new("invalid color value")))
}

/// Parse a named color string into a ratatui Color.
pub fn parse_named_color(name: &str) -> Result<Color, Error> {
    match name {
        "black" => Ok(Color::Black),
        "red" => Ok(Color::Red),
        "green" => Ok(Color::Green),
        "yellow" => Ok(Color::Yellow),
        "blue" => Ok(Color::Blue),
        "magenta" => Ok(Color::Magenta),
        "cyan" => Ok(Color::Cyan),
        "gray" => Ok(Color::Gray),
        "dark_gray" => Ok(Color::DarkGray),
        "light_red" => Ok(Color::LightRed),
        "light_green" => Ok(Color::LightGreen),
        "light_yellow" => Ok(Color::LightYellow),
        "light_blue" => Ok(Color::LightBlue),
        "light_magenta" => Ok(Color::LightMagenta),
        "light_cyan" => Ok(Color::LightCyan),
        "white" => Ok(Color::White),
        "reset" => Ok(Color::Reset),
        other => Err(Error::Term(Box::new(format!("unknown color: {other}")))),
    }
}

/// Parse a modifier name string into a ratatui Modifier.
pub fn parse_modifier(name: &str) -> Result<Modifier, Error> {
    match name {
        "bold" => Ok(Modifier::BOLD),
        "dim" => Ok(Modifier::DIM),
        "italic" => Ok(Modifier::ITALIC),
        "underlined" => Ok(Modifier::UNDERLINED),
        "crossed_out" => Ok(Modifier::CROSSED_OUT),
        "reversed" => Ok(Modifier::REVERSED),
        other => Err(Error::Term(Box::new(format!(
            "unknown modifier: {other}"
        )))),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_all_named_colors() {
        let cases = vec![
            ("black", Color::Black),
            ("red", Color::Red),
            ("green", Color::Green),
            ("yellow", Color::Yellow),
            ("blue", Color::Blue),
            ("magenta", Color::Magenta),
            ("cyan", Color::Cyan),
            ("gray", Color::Gray),
            ("dark_gray", Color::DarkGray),
            ("light_red", Color::LightRed),
            ("light_green", Color::LightGreen),
            ("light_yellow", Color::LightYellow),
            ("light_blue", Color::LightBlue),
            ("light_magenta", Color::LightMagenta),
            ("light_cyan", Color::LightCyan),
            ("white", Color::White),
            ("reset", Color::Reset),
        ];

        for (name, expected) in cases {
            assert_eq!(
                parse_named_color(name).unwrap(),
                expected,
                "failed for color: {name}"
            );
        }
    }

    #[test]
    fn test_parse_unknown_color_returns_error() {
        assert!(parse_named_color("neon_pink").is_err());
    }

    #[test]
    fn test_parse_all_modifiers() {
        let cases = vec![
            ("bold", Modifier::BOLD),
            ("dim", Modifier::DIM),
            ("italic", Modifier::ITALIC),
            ("underlined", Modifier::UNDERLINED),
            ("crossed_out", Modifier::CROSSED_OUT),
            ("reversed", Modifier::REVERSED),
        ];

        for (name, expected) in cases {
            assert_eq!(
                parse_modifier(name).unwrap(),
                expected,
                "failed for modifier: {name}"
            );
        }
    }

    #[test]
    fn test_parse_unknown_modifier_returns_error() {
        assert!(parse_modifier("blink").is_err());
    }
}
