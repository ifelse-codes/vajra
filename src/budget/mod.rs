use std::fs;
use std::path::Path;

#[derive(Debug, Clone, PartialEq)]
pub enum BudgetMode {
    Warn,
    Kill,
}

#[derive(Debug, Clone)]
pub struct BudgetConfig {
    pub cap_usd: f64,
    pub mode: BudgetMode,
}

#[derive(Debug, Clone, PartialEq)]
pub enum BudgetVerdict {
    UnderBudget,
    OverBudget {
        spent: f64,
        cap: f64,
        kill: bool,
    },
    NoCap,
}

pub fn read_budget_config(constraints_path: &Path) -> Option<BudgetConfig> {
    let content = fs::read_to_string(constraints_path).ok()?;
    parse_budget_section(&content)
}

pub fn check_budget(config: Option<&BudgetConfig>, session_cost: f64) -> BudgetVerdict {
    let Some(config) = config else {
        return BudgetVerdict::NoCap;
    };
    if session_cost > config.cap_usd {
        BudgetVerdict::OverBudget {
            spent: session_cost,
            cap: config.cap_usd,
            kill: config.mode == BudgetMode::Kill,
        }
    } else {
        BudgetVerdict::UnderBudget
    }
}

pub fn format_budget_warning(spent: f64, cap: f64, kill: bool) -> String {
    let action = if kill { "KILLED" } else { "WARNING" };
    format!(
        "[vajra budget] {action}: session cost ${spent:.4} exceeds cap ${cap:.2}\n"
    )
}

fn parse_budget_section(content: &str) -> Option<BudgetConfig> {
    let mut in_budget = false;
    let mut cap_usd: Option<f64> = None;
    let mut mode = BudgetMode::Warn;

    for line in content.lines() {
        if line.starts_with("budget:") {
            in_budget = true;
            continue;
        }
        if in_budget
            && !line.starts_with(' ')
            && !line.starts_with('\t')
            && !line.trim().is_empty()
        {
            break;
        }
        if in_budget {
            let trimmed = line.trim();
            if let Some(value) = trimmed.strip_prefix("cap_usd:") {
                cap_usd = value.trim().parse().ok();
            } else if let Some(value) = trimmed.strip_prefix("mode:") {
                if value.trim() == "kill" {
                    mode = BudgetMode::Kill;
                }
            }
        }
    }

    cap_usd.map(|cap| BudgetConfig {
        cap_usd: cap,
        mode,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_budget_section_warn_mode() {
        let yaml = "version: 3\n\nsession:\n  max_assumptions: 2\n\nbudget:\n  cap_usd: 5.00\n  mode: warn\n\ncommit:\n  autonomous: false\n";
        let config = parse_budget_section(yaml).unwrap();
        assert!((config.cap_usd - 5.0).abs() < f64::EPSILON);
        assert_eq!(config.mode, BudgetMode::Warn);
    }

    #[test]
    fn parses_budget_section_kill_mode() {
        let yaml = "budget:\n  cap_usd: 1.50\n  mode: kill\n";
        let config = parse_budget_section(yaml).unwrap();
        assert!((config.cap_usd - 1.5).abs() < f64::EPSILON);
        assert_eq!(config.mode, BudgetMode::Kill);
    }

    #[test]
    fn defaults_to_warn_when_mode_missing() {
        let yaml = "budget:\n  cap_usd: 10.0\n";
        let config = parse_budget_section(yaml).unwrap();
        assert_eq!(config.mode, BudgetMode::Warn);
    }

    #[test]
    fn returns_none_when_no_budget_section() {
        let yaml = "version: 3\nsession:\n  max_assumptions: 2\n";
        assert!(parse_budget_section(yaml).is_none());
    }

    #[test]
    fn returns_none_when_cap_usd_missing() {
        let yaml = "budget:\n  mode: kill\n";
        assert!(parse_budget_section(yaml).is_none());
    }

    #[test]
    fn check_under_budget() {
        let config = BudgetConfig {
            cap_usd: 5.0,
            mode: BudgetMode::Warn,
        };
        assert_eq!(check_budget(Some(&config), 3.50), BudgetVerdict::UnderBudget);
    }

    #[test]
    fn check_over_budget_warn() {
        let config = BudgetConfig {
            cap_usd: 2.0,
            mode: BudgetMode::Warn,
        };
        assert_eq!(
            check_budget(Some(&config), 2.50),
            BudgetVerdict::OverBudget {
                spent: 2.50,
                cap: 2.0,
                kill: false,
            }
        );
    }

    #[test]
    fn check_over_budget_kill() {
        let config = BudgetConfig {
            cap_usd: 1.0,
            mode: BudgetMode::Kill,
        };
        assert_eq!(
            check_budget(Some(&config), 1.50),
            BudgetVerdict::OverBudget {
                spent: 1.50,
                cap: 1.0,
                kill: true,
            }
        );
    }

    #[test]
    fn check_no_config_returns_no_cap() {
        assert_eq!(check_budget(None, 999.0), BudgetVerdict::NoCap);
    }

    #[test]
    fn format_warning_shows_warning_for_warn_mode() {
        let msg = format_budget_warning(3.50, 2.0, false);
        assert!(msg.contains("WARNING"));
        assert!(msg.contains("$3.5000"));
        assert!(msg.contains("$2.00"));
    }

    #[test]
    fn format_warning_shows_killed_for_kill_mode() {
        let msg = format_budget_warning(5.0, 1.0, true);
        assert!(msg.contains("KILLED"));
    }
}
