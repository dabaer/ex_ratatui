use ratatui::layout::{Alignment, Rect};
use rustler::{Atom, Error, Term};
use std::collections::HashMap;

use crate::style::decode_style;
use crate::terminal::with_terminal;
use crate::widgets::paragraph::{self, ParagraphData};

mod atoms {
    rustler::atoms! {
        ok,
    }
}

enum WidgetData {
    Paragraph(ParagraphData),
}

struct RenderCommand {
    widget: WidgetData,
    area: Rect,
}

#[rustler::nif]
fn draw_frame(commands: Term) -> Result<Atom, Error> {
    let command_list: Vec<(Term, Term)> = commands.decode()?;
    let render_commands = decode_commands(&command_list)?;

    with_terminal(|terminal| {
        terminal
            .draw(|frame| {
                for cmd in &render_commands {
                    render_widget(frame, cmd);
                }
            })
            .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

        Ok(atoms::ok())
    })
}

fn decode_commands(commands: &[(Term, Term)]) -> Result<Vec<RenderCommand>, Error> {
    commands
        .iter()
        .map(|(widget_term, rect_term)| {
            let widget_map: HashMap<String, Term> = widget_term.decode()?;
            let widget_type: String = widget_map
                .get("type")
                .ok_or_else(|| Error::Term(Box::new("widget missing 'type' key")))?
                .decode()?;

            let widget = match widget_type.as_str() {
                "paragraph" => WidgetData::Paragraph(decode_paragraph(&widget_map)?),
                other => {
                    return Err(Error::Term(Box::new(format!(
                        "unknown widget type: {other}"
                    ))))
                }
            };

            Ok(RenderCommand {
                widget,
                area: decode_rect(*rect_term)?,
            })
        })
        .collect()
}

fn decode_paragraph(map: &HashMap<String, Term>) -> Result<ParagraphData, Error> {
    let text: String = map
        .get("text")
        .ok_or_else(|| Error::Term(Box::new("paragraph missing 'text'")))?
        .decode()?;

    let style = match map.get("style") {
        Some(term) => decode_style(*term)?,
        None => ratatui::style::Style::default(),
    };

    let alignment = match map.get("alignment") {
        Some(term) => {
            let s: String = term.decode()?;
            match s.as_str() {
                "center" => Alignment::Center,
                "right" => Alignment::Right,
                _ => Alignment::Left,
            }
        }
        None => Alignment::Left,
    };

    let wrap: bool = match map.get("wrap") {
        Some(term) => term.decode()?,
        None => false,
    };

    let scroll_y: u16 = match map.get("scroll_y") {
        Some(term) => term.decode()?,
        None => 0,
    };
    let scroll_x: u16 = match map.get("scroll_x") {
        Some(term) => term.decode()?,
        None => 0,
    };

    Ok(ParagraphData {
        text,
        style,
        alignment,
        wrap,
        scroll: (scroll_y, scroll_x),
    })
}

pub fn decode_rect(term: Term) -> Result<Rect, Error> {
    let map: HashMap<String, Term> = term.decode()?;
    Ok(Rect {
        x: map
            .get("x")
            .ok_or_else(|| Error::Term(Box::new("rect missing 'x'")))?
            .decode()?,
        y: map
            .get("y")
            .ok_or_else(|| Error::Term(Box::new("rect missing 'y'")))?
            .decode()?,
        width: map
            .get("width")
            .ok_or_else(|| Error::Term(Box::new("rect missing 'width'")))?
            .decode()?,
        height: map
            .get("height")
            .ok_or_else(|| Error::Term(Box::new("rect missing 'height'")))?
            .decode()?,
    })
}

fn render_widget(frame: &mut ratatui::Frame, cmd: &RenderCommand) {
    match &cmd.widget {
        WidgetData::Paragraph(data) => paragraph::render(frame, data, cmd.area),
    }
}
