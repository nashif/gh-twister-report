# gh twister-report

A [`gh`](https://cli.github.com/) CLI extension for the Zephyr project that
downloads artifacts from the [`twister.yaml`](../../../.github/workflows/twister.yaml)
workflow, merges the individual `twister.json` files into a single combined
document, and generates a failure report.

The analysis logic mirrors
[`scripts/ci/twister_report_analyzer.py`](../twister_report_analyzer.py).

---

## Requirements

- [`gh` CLI](https://cli.github.com/) ≥ 2.x, authenticated (`gh auth login`)
- Python 3.10+

---

## Installation

`gh extension install` requires the source directory to be its own git
repository.  Use the provided `install.sh` helper, which creates a temporary
git repo and installs from it automatically:

```sh
# From the Zephyr repository root:
./scripts/ci/gh-twister-report/install.sh

# Or from inside the extension directory:
cd scripts/ci/gh-twister-report && ./install.sh
```

Alternatively, place (or symlink) the `gh-twister-report` executable anywhere
on your `$PATH` — the `gh` CLI will discover it automatically:

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
| `--long-summary` | — | Print all matched errors (default: top-15 only) |
| `--status` | — | Print testsuite/testcase status counters |
| `--platforms` | — | Print error counts grouped by platform |
| `-ll LEVEL` | `INFO` | Log verbosity: DEBUG, INFO, WARNING, ERROR, CRITICAL |

---

## Examples

```sh
# Report for a specific run
gh twister-report --run-id 1234567890

# Report for the latest twister run on PR #12345
gh twister-report --pr 12345

# Full verbose report on the main branch, save CSV and Markdown
gh twister-report --branch main \
    --long-summary --platforms \
    --output-csv errors.csv \
    --output-md errors.md

# Re-analyse already-downloaded artifacts without hitting the API
gh twister-report --no-download --artifacts-dir ./twister-artifacts --long-summary
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
