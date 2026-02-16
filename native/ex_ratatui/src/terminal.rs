use std::io::Stdout;
use std::sync::Mutex;

use crossterm::terminal::{self, EnterAlternateScreen, LeaveAlternateScreen};
use crossterm::ExecutableCommand;
use ratatui::backend::CrosstermBackend;
use ratatui::Terminal;

use rustler::Error;

/// Global terminal state — one terminal per BEAM node.
static TERMINAL: Mutex<Option<Terminal<CrosstermBackend<Stdout>>>> = Mutex::new(None);

/// Access the global terminal (locked).
pub fn with_terminal<F, R>(f: F) -> Result<R, Error>
where
    F: FnOnce(&mut Terminal<CrosstermBackend<Stdout>>) -> Result<R, Error>,
{
    let mut guard = TERMINAL.lock().map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;
    let terminal = guard
        .as_mut()
        .ok_or_else(|| Error::Term(Box::new("terminal not initialized")))?;
    f(terminal)
}

#[rustler::nif]
fn init_terminal() -> Result<(), Error> {
    terminal::enable_raw_mode().map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
    std::io::stdout()
        .execute(EnterAlternateScreen)
        .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let backend = CrosstermBackend::new(std::io::stdout());
    let terminal =
        Terminal::new(backend).map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let mut guard = TERMINAL.lock().map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;
    *guard = Some(terminal);
    Ok(())
}

#[rustler::nif]
fn restore_terminal() -> Result<(), Error> {
    terminal::disable_raw_mode().map_err(|e| Error::Term(Box::new(format!("{e}"))))?;
    std::io::stdout()
        .execute(LeaveAlternateScreen)
        .map_err(|e| Error::Term(Box::new(format!("{e}"))))?;

    let mut guard = TERMINAL.lock().map_err(|_| Error::Term(Box::new("terminal lock poisoned")))?;
    *guard = None;
    Ok(())
}

#[rustler::nif]
fn terminal_size() -> Result<(u16, u16), Error> {
    terminal::size().map_err(|e| Error::Term(Box::new(format!("{e}"))))
}
