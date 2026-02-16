use ratatui::layout::{Constraint, Direction, Layout};
use rustler::{Error, Term};
use std::collections::HashMap;

use crate::rendering::decode_rect;

#[rustler::nif]
fn layout_split(
    area_term: Term,
    direction: String,
    constraints_term: Vec<Term>,
) -> Result<Vec<(u16, u16, u16, u16)>, Error> {
    let area = decode_rect(area_term)?;

    let dir = match direction.as_str() {
        "horizontal" => Direction::Horizontal,
        "vertical" => Direction::Vertical,
        other => {
            return Err(Error::Term(Box::new(format!(
                "unknown direction: {other}"
            ))))
        }
    };

    let constraints: Vec<Constraint> = constraints_term
        .iter()
        .map(|t| decode_constraint(*t))
        .collect::<Result<_, _>>()?;

    let chunks = Layout::default()
        .direction(dir)
        .constraints(constraints)
        .split(area);

    Ok(chunks.iter().map(|r| (r.x, r.y, r.width, r.height)).collect())
}

pub fn decode_constraint(term: Term) -> Result<Constraint, Error> {
    let map: HashMap<String, Term> = term.decode()?;
    let constraint_type: String = map
        .get("type")
        .ok_or_else(|| Error::Term(Box::new("constraint missing 'type'")))?
        .decode()?;

    match constraint_type.as_str() {
        "percentage" => {
            let value: u16 = map
                .get("value")
                .ok_or_else(|| Error::Term(Box::new("percentage missing 'value'")))?
                .decode()?;
            Ok(Constraint::Percentage(value))
        }
        "length" => {
            let value: u16 = map
                .get("value")
                .ok_or_else(|| Error::Term(Box::new("length missing 'value'")))?
                .decode()?;
            Ok(Constraint::Length(value))
        }
        "min" => {
            let value: u16 = map
                .get("value")
                .ok_or_else(|| Error::Term(Box::new("min missing 'value'")))?
                .decode()?;
            Ok(Constraint::Min(value))
        }
        "max" => {
            let value: u16 = map
                .get("value")
                .ok_or_else(|| Error::Term(Box::new("max missing 'value'")))?
                .decode()?;
            Ok(Constraint::Max(value))
        }
        "ratio" => {
            let num: u32 = map
                .get("num")
                .ok_or_else(|| Error::Term(Box::new("ratio missing 'num'")))?
                .decode()?;
            let den: u32 = map
                .get("den")
                .ok_or_else(|| Error::Term(Box::new("ratio missing 'den'")))?
                .decode()?;
            Ok(Constraint::Ratio(num, den))
        }
        other => Err(Error::Term(Box::new(format!(
            "unknown constraint type: {other}"
        )))),
    }
}

#[cfg(test)]
mod tests {
    use ratatui::layout::{Constraint, Direction, Layout, Rect};

    #[test]
    fn test_vertical_split_percentage() {
        let area = Rect::new(0, 0, 80, 24);
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
            .split(area);

        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0], Rect::new(0, 0, 80, 12));
        assert_eq!(chunks[1], Rect::new(0, 12, 80, 12));
    }

    #[test]
    fn test_horizontal_split_percentage() {
        let area = Rect::new(0, 0, 80, 24);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
            .split(area);

        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0], Rect::new(0, 0, 40, 24));
        assert_eq!(chunks[1], Rect::new(40, 0, 40, 24));
    }

    #[test]
    fn test_vertical_split_length() {
        let area = Rect::new(0, 0, 80, 24);
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Length(3), Constraint::Min(0)])
            .split(area);

        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0].height, 3);
        assert_eq!(chunks[1].height, 21);
        assert_eq!(chunks[1].y, 3);
    }

    #[test]
    fn test_three_way_split() {
        let area = Rect::new(0, 0, 60, 30);
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(3),
                Constraint::Min(0),
                Constraint::Length(1),
            ])
            .split(area);

        assert_eq!(chunks.len(), 3);
        assert_eq!(chunks[0], Rect::new(0, 0, 60, 3));
        assert_eq!(chunks[1], Rect::new(0, 3, 60, 26));
        assert_eq!(chunks[2], Rect::new(0, 29, 60, 1));
    }

    #[test]
    fn test_split_with_offset() {
        let area = Rect::new(5, 5, 40, 20);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
            .split(area);

        assert_eq!(chunks[0], Rect::new(5, 5, 20, 20));
        assert_eq!(chunks[1], Rect::new(25, 5, 20, 20));
    }

    #[test]
    fn test_ratio_constraint() {
        let area = Rect::new(0, 0, 90, 24);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Ratio(1, 3), Constraint::Ratio(2, 3)])
            .split(area);

        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0].width, 30);
        assert_eq!(chunks[1].width, 60);
    }

    #[test]
    fn test_max_constraint() {
        let area = Rect::new(0, 0, 80, 24);
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Max(5), Constraint::Min(0)])
            .split(area);

        assert_eq!(chunks[0].height, 5);
        assert_eq!(chunks[1].height, 19);
    }
}
