# Zsh Completions

This directory contains Zsh completion files for custom scripts.

## Installation

### Option 1: Add to your fpath (Recommended)

Add the completions directory to your `$fpath` in your `.zshrc`:

```zsh
# Add custom completions to fpath
fpath=(~/path/to/dotfiles/completions $fpath)

# Initialize completions
autoload -Uz compinit && compinit
```

### Option 2: Copy to system completions directory

Copy the completion files to a system completions directory:

```bash
# For user-specific completions
mkdir -p ~/.local/share/zsh/completions
cp dotfiles/completions/* ~/.local/share/zsh/completions/

# Add to .zshrc
fpath=(~/.local/share/zsh/completions $fpath)
autoload -Uz compinit && compinit
```

### Option 3: Source directly

You can also source the completion files directly in your `.zshrc`:

```zsh
# Source completions directly
source ~/path/to/dotfiles/completions/_issue
```

## Available Completions

### `_issue`

Provides tab completion for the `issue.zsh` script:

- **Commands**: Complete all available subcommands (create, list, view, open, edit, comment, close, closeWithCommit)
- **Issue numbers**: When using commands that take issue numbers, provides completion with issue titles
- **Labels**: For the `list` command, provides completion of available repository labels

#### Features

- Dynamically fetches open issues from the current repository using `gh issue list`
- Displays issue numbers with their titles for easy identification
- Provides label completion for filtering issues
- Gracefully handles cases where `gh` CLI is not available or not in a git repository

#### Usage Examples

```bash
issue <TAB>                    # Shows all available commands
issue view <TAB>               # Shows list of open issues with titles
issue list <TAB>               # Shows available labels for filtering
issue edit 1<TAB>              # Completes issue numbers starting with 1
```

## Adding New Completions

To add a new completion file:

1. Create a file starting with `_` followed by the command name (e.g., `_mycommand`)
2. Use the `#compdef mycommand` directive at the top
3. Follow the Zsh completion function patterns shown in existing files
4. Test the completion by sourcing the file or restarting your shell

## Requirements

- Zsh shell
- For `_issue`: `gh` CLI tool and `jq` for JSON parsing
- Git repository (for issue-related completions)

