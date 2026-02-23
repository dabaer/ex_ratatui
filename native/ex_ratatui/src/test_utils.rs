#[cfg(test)]
pub mod helpers {
    use ratatui::backend::TestBackend;
    use ratatui::Terminal;

    /// Read a single line from the test backend buffer, trimming trailing whitespace.
    pub fn buffer_line(terminal: &Terminal<TestBackend>, y: u16, width: u16) -> String {
        let buf = terminal.backend().buffer();
        (0..width)
            .map(|x| buf.cell((x, y)).map_or(" ", |c| c.symbol()).to_string())
            .collect::<String>()
            .trim_end()
            .to_string()
    }
}
