# gh twister-report

A [`gh`](https://cli.github.com/) CLI extension for the Zephyr project that
downloads artifacts from the [`twister.yaml`](../../../.github/workflows/twister.yaml)
workflow, merges the individual `twister.json` files into a single combined
document, and generates a failure report with a rich terminal visual summary.

The analysis logic mirrors
[`scripts/ci/twister_report_analyzer.py`](../twister_report_analyzer.py).

---

## Requirements

- [`gh` CLI](https://cli.github.com/) ≥ 2.x, authenticated (`gh auth login`)
- Python 3.10+

---

## Installation

`gh extension install` requires the source directory to be its own git
repository. Use the provided helper script which handles this automatically:

```sh
# From the Zephyr repository root:
./scripts/ci/gh-twister-report/install.sh

# Or from inside the extension directory:
cd scripts/ci/gh-twister-report && ./install.sh
```

Alternatively, place (or symlink) the executable anywhere on your `$PATH` —
the `gh` CLI will discover it automatically:

```sh
ln -s "$PWD/scripts/ci/gh-twister-report/gh-twister-report" ~/.local/bin/gh-twister-report
```

---

## Usage

```
gh twister-report [run selection] [download options] [output options]
```

### Run selection (pick one)

| Flag | Description |
|------|-------------|
| `--run-id ID` | Use a specific GitHub Actions workflow run ID |
| `--pr NUMBER` | Use the most recent twister run for a pull request |
| `--branch NAME` | Use the most recent twister run on a branch (default: `main`) |

### Download options

| Flag | Default | Description |
|------|---------|-------------|
| `--repo OWNER/REPO` | current repo | Target repository |
| `--artifacts-dir DIR` | `twister-artifacts` | Where to store downloaded artifacts |
| `--no-download` | — | Skip download; read from `--artifacts-dir` directly |
| `--keep-artifacts` | — | Do not remove the artifact directory after analysis |

### Output options

| Flag | Default | Description |
|------|---------|-------------|
| `--merged-json FILE` | `twister_merged.json` | Path for the merged twister JSON |
| `--output FILE` | `twister_report_summary.json` | Path for the analysis summary JSON |
| `--output-csv FILE` | — | Also write a CSV error summary |
| `--output-md FILE` | — | Also write a Markdown error table |
| `--long-summary` | — | Show all matched errors (default: top-15 only) |
| `--platforms` | — | Show error counts grouped by platform |
| `--no-color` | — | Disable coloured terminal output |
| `-ll LEVEL` | `WARNING` | Log verbosity: DEBUG, INFO, WARNING, ERROR, CRITICAL |

---

## Examples

```sh
# Report for a specific run
gh twister-report --run-id 1234567890

# Report for the latest twister run on PR #12345
gh twister-report --pr 12345

# Full report with platform breakdown, save CSV and Markdown
gh twister-report --branch main \
    --long-summary --platforms \
    --output-csv errors.csv \
    --output-md errors.md

# Re-analyse already-downloaded artifacts without hitting the API
gh twister-report --no-download --artifacts-dir ./twister-artifacts --long-summary
```

---

## Sample output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TWISTER REPORT  —  run 1234567890  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Artifacts: 25 subset(s)   Total testsuites: 12,450   Merged JSON: twister_merged.json

  STATUS SUMMARY
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ passed      9,823   78.9%  ████████████████████████████████████████████████████████░░░░░░░░░░ │
  │ failed      1,204    9.7%  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
  │ error         312    2.5%  ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
  │ skipped       876    7.0%  █████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
  │ filtered      235    1.9%  █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘

  FAILURE BREAKDOWN  1,516 testsuite(s) with errors/failures
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  COUNT  REASON                                                                                 │
  ├────────────────────────────────────────────────────────────────────────────────────────────────┤
  │    412  Build failure                                         27.2%  ████████░░░░░░░░░░░░░░░░ │
  │    298  CMake build failure                                   19.7%  █████░░░░░░░░░░░░░░░░░░░ │
  │    187  Timeout                                               12.3%  ███░░░░░░░░░░░░░░░░░░░░░ │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘

──────────────────────────────────────────────────────────────────────────────────────────────────
  [ 78.9% passed ]  passed=9,823  failed=1,516  total=12,450
```

---

## Workflow artifact structure

Each `twister-build` matrix job uploads an artifact named
**`Unit Test Results (Subset N)`** containing:

```
twister-out/twister.json   ← merged by this extension
twister-out/twister.xml
module_tests/twister.xml
testplan.json
```

All `twister.json` files across all subsets are merged into a single
`twister_merged.json` before analysis.
