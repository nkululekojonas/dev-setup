# C Dev Setup Automator

A bash script that automates C project setup with proper directory structure, dependency checking, and git initialization.

## What it does

- Creates standard C project layout (`src/`, `include/`, `build/`, `docs/`)
- Detects and installs missing tools (gcc, make, git, ack)
- Initializes git repository with sensible `.gitignore`
- Generates project config file with timestamp and detected tools
- Works on macOS (brew) and Linux (apt/dnf/pacman)

## Usage

```bash
dev-setup.sh project_name
```

## Requirements

The script will attempt to install missing tools, but you need:
- macOS: Homebrew
- Linux: One of apt, dnf, or pacman

## Example

```bash
dev-setup.sh my-c-project
cd my-c-project
# Ready to code - src/ and include/ directories created
```

## Output structure

```
my-c-project/
├── src/
├── include/
├── build/
├── docs/
├── .gitignore
├── README.md
└── project-config.txt
```

## Future improvements

- **Dry run mode** (`--dry-run` flag) - preview changes without creating files
- **Template support** - choose from project templates (CLI app, library, etc.)
- **Makefile generation** - auto-create basic Makefile with common targets
- **Config file** - load defaults from `~/.cdevrc` (preferred compiler, flags)
- **CMake option** - generate CMakeLists.txt instead of Makefile
- **Verbose/quiet flags** - control output detail level
- **License selection** - prompt for and add LICENSE file
- **Skip prompts** - `--force` flag to overwrite without confirmation
- **Custom directory structure** - define your own layout via config

## Notes

- Overwrites existing directories with user confirmation
- Skips git setup if git unavailable
- Logs tool detection status to `project-config.txt`
