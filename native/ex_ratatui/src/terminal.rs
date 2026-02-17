use std::io::Stdout;
use std::sync::Mutex;

use crossterm::terminal::{self, EnterAlternateScreen, LeaveAlternateScreen};
use crossterm::ExecutableCommand;
use ratatui::backend::{CrosstermBackend, TestBackend};
use ratatui::Terminal;

use rustler::{Atom, Error};

mod atoms {
    rustler::atoms! {
        ok,
    }
}

/// Supports both real (crossterm) and test (headless) terminals.
enum AnyTerminal {
    Crossterm(Terminal<CrosstermBackend<Stdout>>),
    Test(Terminal<TestBackend>),
}

/// Global terminal state — one terminal per BEAM node.
static TERMINAL: Mutex<Option<AnyTerminal>> = Mutex::new(None);

/// Draw a frame using whichever terminal is currently initialized.
pub fn with_terminal_draw<F>(f: F) -> Result<Atom, Error>
where
    F: FnOnce(&mut ratatui::Frame),
{
    let mut guard = TERMINAL
        .lock()
        .map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;
    let terminal = guard
        .as_mut()
        .ok_or_else(|| Error::Term(Box::new("terminal not initialized")))?;

    let draw_result = match terminal {
        AnyTerminal::Crossterm(t) => t.draw(f),
        AnyTerminal::Test(t) => t.draw(f).map_err(|e| std::io::Error::other(e)),
    };

    draw_result.map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
    Ok(atoms::ok())
}

#[rustler::nif]
fn init_terminal() -> Result<Atom, Error> {
    terminal::enable_raw_mode().map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
    std::io::stdout()
        .execute(EnterAlternateScreen)
        .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let backend = CrosstermBackend::new(std::io::stdout());
    let terminal = Terminal::new(backend).map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let mut guard = TERMINAL
        .lock()
        .map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;
    *guard = Some(AnyTerminal::Crossterm(terminal));
    Ok(atoms::ok())
}

#[rustler::nif]
fn restore_terminal() -> Result<Atom, Error> {
    let mut guard = TERMINAL
        .lock()
        .map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;

    match guard.take() {
        Some(AnyTerminal::Crossterm(_)) => {
            terminal::disable_raw_mode()
                .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
            std::io::stdout()
                .execute(LeaveAlternateScreen)
                .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
        }
        Some(AnyTerminal::Test(_)) => {
            // No cleanup needed for test backend
        }
        None => {
            // Already cleaned up, safe no-op
        }
    }

    Ok(atoms::ok())
}

#[rustler::nif]
fn terminal_size() -> Result<(u16, u16), Error> {
    terminal::size().map_err(|e| Error::Term(Box::new(format!("{e}"))))
}

#[rustler::nif]
fn init_test_terminal(width: u16, height: u16) -> Result<Atom, Error> {
    let backend = TestBackend::new(width, height);
    let terminal = Terminal::new(backend).map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let mut guard = TERMINAL
        .lock()
        .map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;

    // Clean up any existing real terminal
    if let Some(AnyTerminal::Crossterm(_)) = guard.as_ref() {
        let _ = terminal::disable_raw_mode();
        let _ = std::io::stdout().execute(LeaveAlternateScreen);
    }

    *guard = Some(AnyTerminal::Test(terminal));
    Ok(atoms::ok())
}

#[rustler::nif]
fn get_buffer_content() -> Result<String, Error> {
    let guard = TERMINAL
        .lock()
        .map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;

    match guard.as_ref() {
        Some(AnyTerminal::Test(t)) => {
            let buf = t.backend().buffer();
            let mut lines = Vec::new();
            for y in 0..buf.area.height {
                let line: String = (0..buf.area.width)
                    .map(|x| {
                        buf.cell((x, y))
                            .map_or(" ", |c| c.symbol())
                            .to_string()
                    })
                    .collect();
                lines.push(line.trim_end().to_string());
            }
            // Trim trailing empty lines
            while lines.last().is_some_and(|l| l.is_empty()) {
                lines.pop();
            }
            Ok(lines.join("\n"))
        }
        Some(AnyTerminal::Crossterm(_)) => Err(Error::Term(Box::new(
            "get_buffer_content requires a test terminal",
        ))),
        None => Err(Error::Term(Box::new("terminal not initialized"))),
    }
}
