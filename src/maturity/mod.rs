use std::fmt;
use std::fs;
use std::path::Path;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MaturityLevel {
    L1,
    L2,
    L3,
}

impl MaturityLevel {
    pub fn label(self) -> &'static str {
        match self {
            Self::L1 => "Report",
            Self::L2 => "Gated",
            Self::L3 => "Auto",
        }
    }
}

impl fmt::Display for MaturityLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::L1 => write!(f, "L1"),
            Self::L2 => write!(f, "L2"),
            Self::L3 => write!(f, "L3"),
        }
    }
}

pub fn read_maturity(constraints_path: &Path) -> MaturityLevel {
    fs::read_to_string(constraints_path)
        .ok()
        .and_then(|content| parse_maturity(&content))
        .unwrap_or(MaturityLevel::L2)
}

fn parse_maturity(content: &str) -> Option<MaturityLevel> {
    for line in content.lines() {
        let trimmed = line.trim();
        if let Some(value) = trimmed.strip_prefix("maturity:") {
            return match value.trim() {
                "L1" => Some(MaturityLevel::L1),
                "L2" => Some(MaturityLevel::L2),
                "L3" => Some(MaturityLevel::L3),
                _ => None,
            };
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_l1() {
        assert_eq!(parse_maturity("maturity: L1\n"), Some(MaturityLevel::L1));
    }

    #[test]
    fn parses_l2() {
        assert_eq!(parse_maturity("maturity: L2\n"), Some(MaturityLevel::L2));
    }

    #[test]
    fn parses_l3() {
        assert_eq!(parse_maturity("maturity: L3\n"), Some(MaturityLevel::L3));
    }

    #[test]
    fn returns_none_when_missing() {
        assert_eq!(parse_maturity("version: 3\nsession:\n"), None);
    }

    #[test]
    fn returns_none_for_invalid_value() {
        assert_eq!(parse_maturity("maturity: L4\n"), None);
    }

    #[test]
    fn defaults_to_l2_when_missing() {
        let tmp = tempfile::tempdir().unwrap();
        let path = tmp.path().join("CONSTRAINTS.yaml");
        fs::write(&path, "version: 3\n").unwrap();
        assert_eq!(read_maturity(&path), MaturityLevel::L2);
    }

    #[test]
    fn reads_from_file() {
        let tmp = tempfile::tempdir().unwrap();
        let path = tmp.path().join("CONSTRAINTS.yaml");
        fs::write(&path, "version: 3\nmaturity: L3\n").unwrap();
        assert_eq!(read_maturity(&path), MaturityLevel::L3);
    }

    #[test]
    fn indented_maturity_parsed() {
        let yaml = "version: 3\n  maturity: L1\n";
        assert_eq!(parse_maturity(yaml), Some(MaturityLevel::L1));
    }

    #[test]
    fn display_format() {
        assert_eq!(format!("{}", MaturityLevel::L1), "L1");
        assert_eq!(format!("{}", MaturityLevel::L2), "L2");
        assert_eq!(format!("{}", MaturityLevel::L3), "L3");
    }

    #[test]
    fn labels() {
        assert_eq!(MaturityLevel::L1.label(), "Report");
        assert_eq!(MaturityLevel::L2.label(), "Gated");
        assert_eq!(MaturityLevel::L3.label(), "Auto");
    }
}
