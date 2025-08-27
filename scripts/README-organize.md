# Script Organization Tool

This tool organizes scripts into individual directories with complete publishing infrastructure.

## Usage

```bash
# Preview what will be done (recommended first)
./organize-scripts.sh --dry-run

# Organize scripts into directories
./organize-scripts.sh

# Organize AND publish (create dist symlinks)
./organize-scripts.sh --publish

# Preview with publish mode
./organize-scripts.sh --dry-run --publish
```

## What It Does

### 1. Script Organization
- Creates individual directories for each script (flat structure under scripts/source/)
- Moves scripts from category subdirectories to their own source directories
- Maintains backup of original structure

### 2. Documentation Generation
- **README.md**: Documentation template with usage, requirements, notes
- **metadata.json**: Machine-readable metadata for package managers
- **install.sh**: Installation script for distribution

### 3. Completion System
- Creates zsh completion stubs for each script
- Supports basic help/version flags and file completion
- Ready for customization

### 4. Publishing Infrastructure
- **dist/** directory: Symlinks to all scripts for PATH integration
- **completions/** directory: Symlinks to all completions for zsh

## Integration with install.zsh

The updated `install.zsh` will:
1. First try to add `dist/` directory to PATH (contains all scripts)
2. Fall back to individual category directories if dist doesn't exist
3. Automatically load completions from `completions/` directory

## Directory Structure

After organization:
```
scripts/
├── organize-scripts.sh          # This tool
├── README-organize.md           # This documentation
├── source/                      # All organized scripts
│   ├── pasteToEmulator/        # Individual script directory
│   │   ├── pasteToEmulator.sh  # The actual script
│   │   ├── README.md           # Documentation
│   │   ├── metadata.json       # Package metadata
│   │   └── _pasteToEmulator    # Zsh completion
│   └── deeplink/
│       ├── deeplink.sh
│       ├── README.md
│       ├── metadata.json
│       └── _deeplink
├── dist/                        # Symlinks to all scripts (for PATH)
│   ├── pasteToEmulator -> ../source/pasteToEmulator/pasteToEmulator.sh
│   ├── deeplink -> ../source/deeplink/deeplink.sh
│   └── ...
└── completions/                 # Symlinks to all completions (for zsh)
    ├── _pasteToEmulator -> ../source/pasteToEmulator/_pasteToEmulator
    ├── _deeplink -> ../source/deeplink/_deeplink
    └── ...
```

## Package Distribution

Each script directory becomes a distributable package with:
- **Executable**: The script itself
- **Documentation**: README with usage and requirements
- **Metadata**: JSON file for package managers
- **Completion**: Zsh completion script
- **Installer**: Shell script for system installation

## Workflow

1. **Organize**: `./organize-scripts.sh` - Sets up directory structure
2. **Publish**: `./organize-scripts.sh --publish` - Creates symlinks for easy access
3. **Use**: Scripts are available in PATH via `dist/` directory
4. **Distribute**: Each script directory can be packaged independently

## Notes

- Always run with `--dry-run` first to preview changes
- Backup is created automatically before any changes
- No naming conflicts detected (all script names are unique)
- Completions are basic stubs - customize as needed
- Compatible with existing install.zsh (backward compatible)
