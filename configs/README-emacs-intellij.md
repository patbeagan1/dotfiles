# Emacs Configuration for IntelliJ Developers

This Emacs configuration provides IntelliJ IDEA-like keybindings and features, designed for developers who are experienced with IntelliJ and want similar functionality in Emacs.

## Features

### Navigation
- **Go to File** (`Cmd+Shift+O` / `Ctrl+Shift+O`) - Quickly navigate to any file
- **Go to Symbol** (`Cmd+Alt+O` / `Ctrl+Alt+O`) - Jump to symbols/functions in current file
- **Go to Line** (`Cmd+L` / `Ctrl+L`) - Jump to specific line number
- **Recent Files** (`Cmd+E` / `Ctrl+E`) - Access recently opened files
- **Jump to Definition** (`Cmd+B` / `Ctrl+B`) - Go to symbol definition
- **Find Usages** (`Alt+F7`) - Find all usages of a symbol
- **Go to Implementation** (`Cmd+Alt+B` / `Ctrl+Alt+B`) - Navigate to implementation

### Search and Replace
- **Find** (`Cmd+F` / `Ctrl+F`) - Search in current file
- **Replace** (`Cmd+R` / `Ctrl+R`) - Replace in current file
- **Find in Project** (`Cmd+Shift+F` / `Ctrl+Shift+F`) - Search across project
- **Replace in Project** (`Cmd+Shift+R` / `Ctrl+Shift+R`) - Replace across project

### Editing
- **Duplicate Line** (`Cmd+D` / `Ctrl+D`) - Duplicate current line
- **Delete Line** (`Cmd+Backspace` / `Ctrl+Backspace`) - Delete entire line
- **Move Line Up/Down** (`Alt+Shift+Up/Down`) - Move lines vertically
- **Comment/Uncomment** (`Cmd+/` / `Ctrl+/`) - Toggle comments
- **Join Lines** (`Cmd+Shift+J` / `Ctrl+Shift+J`) - Join multiple lines
- **Multiple Cursors** (`Ctrl+Shift+C`) - Multi-caret editing

### Code Folding
- **Fold** (`Cmd+Alt+-` / `Ctrl+Alt+-`) - Fold current block
- **Unfold** (`Cmd+Alt++` / `Ctrl+Alt++`) - Unfold current block
- **Fold All** (`Cmd+Alt+Shift+-`) - Fold all blocks
- **Unfold All** (`Cmd+Alt+Shift++`) - Unfold all blocks

### Refactoring
- **Rename Symbol** (`Shift+F6`) - Rename symbol across project
- **Extract Method** (`Cmd+Alt+M` / `Ctrl+Alt+M`) - Extract code to method
- **Extract Variable** (`Cmd+Alt+V` / `Ctrl+Alt+V`) - Extract expression to variable

### Window Management
- **Project View** (`Cmd+1` / `Ctrl+1`) - Show project tree
- **Structure View** (`Cmd+7` / `Ctrl+7`) - Show file structure
- **Terminal** (`Alt+F12`) - Open integrated terminal

### Version Control
- **Commit** (`Cmd+K` / `Ctrl+K`) - Git commit
- **Push** (`Cmd+Shift+K` / `Ctrl+Shift+K`) - Git push
- **Status** (`Cmd+X G`) - Git status

### Build and Run
- **Build** (`Cmd+F9` / `Ctrl+F9`) - Compile project
- **Run** (`C-c r`) - Run project
- **Stop** (`Cmd+.` / `Ctrl+.`) - Stop running process

### Code Analysis
- **Next Error** (`F2`) - Navigate to next error/warning
- **Previous Error** (`Shift+F2`) - Navigate to previous error/warning
- Real-time error checking with flycheck

### Code Templates
- **Insert Template** (`Cmd+J` / `Ctrl+J`) - Expand code snippet
- Pre-configured snippets for common patterns

## Installation

### Prerequisites

- Emacs 26.1 or later
- Internet connection (for package downloads)

### Quick Install

1. **Copy the configuration file:**
   ```bash
   cp dotfiles/configs/init.el ~/.emacs.d/init.el
   ```

   Or if you want to use a separate config directory:
   ```bash
   mkdir -p ~/.emacs.d
   cp dotfiles/configs/init.el ~/.emacs.d/init.el
   ```

2. **Start Emacs:**
   ```bash
   emacs
   ```

3. **Wait for packages to install:**
   The first time you start Emacs with this configuration, it will automatically download and install all required packages. This may take a few minutes.

### Manual Installation

If you prefer to manage your Emacs configuration differently:

1. **Add to your existing `~/.emacs` or `~/.emacs.d/init.el`:**
   ```elisp
   (load-file "~/path/to/dotfiles/configs/init.el")
   ```

2. **Or use a symbolic link:**
   ```bash
   ln -s ~/path/to/dotfiles/configs/init.el ~/.emacs.d/init.el
   ```

## Package Dependencies

This configuration uses the following major packages:

- **ivy/counsel/swiper** - Navigation and search
- **projectile** - Project management
- **lsp-mode** - Language Server Protocol support
- **company** - Autocompletion
- **magit** - Git integration
- **flycheck** - Error checking
- **yasnippet** - Code templates
- **multiple-cursors** - Multi-caret editing
- **doom-themes** - Modern themes
- **doom-modeline** - Enhanced modeline

All packages are automatically installed via `package.el` on first startup.

## Language Support

The configuration includes support for:

- **Python** - Full LSP support
- **Rust** - Full LSP support
- **Go** - Full LSP support
- **Java** - Basic support (requires additional LSP server)
- **Kotlin** - Basic support (requires additional LSP server)
- **TypeScript/JavaScript** - Full LSP support

### Setting up Language Servers

For full language support, you may need to install language servers:

- **Python**: `pip install python-language-server` or use `pyright`
- **Rust**: Install via `rustup` (rust-analyzer is included)
- **Go**: `go install golang.org/x/tools/gopls@latest`
- **TypeScript**: `npm install -g typescript-language-server`

## Customization

### Changing Themes

To change the theme, edit `init.el` and replace:
```elisp
(load-theme 'doom-one t)
```

With your preferred theme, for example:
```elisp
(load-theme 'doom-dracula t)
```

### Adjusting Keybindings

All keybindings are defined in the `init.el` file. You can modify them to match your preferences. Look for sections marked with comments like:
```elisp
;;; Navigation (IntelliJ-style)
```

### Adding Language Support

To add support for additional languages:

1. Install the language mode:
   ```elisp
   (use-package your-language-mode
     :ensure t)
   ```

2. Enable LSP for that language:
   ```elisp
   :hook
   ((your-language-mode . lsp))
   ```

## Troubleshooting

### Packages not installing

If packages fail to install:

1. Check your internet connection
2. Try refreshing package archives:
   ```elisp
   M-x package-refresh-contents
   ```
3. Manually install packages:
   ```elisp
   M-x package-install RET package-name RET
   ```

### LSP not working

If LSP features aren't working:

1. Ensure the language server is installed for your language
2. Check LSP logs: `M-x lsp-workspace-show-log`
3. Verify LSP is enabled: `M-x lsp-mode`

### Keybindings not working

If keybindings don't work:

1. Check for conflicts: `M-x which-key`
2. Verify the keybinding: `C-h k` then press your key combination
3. Check if a package is overriding the binding

### Performance Issues

If Emacs is slow:

1. Increase garbage collection threshold (already configured)
2. Disable unused packages
3. Use `profiler-start` to identify bottlenecks

## Keybinding Reference

### Navigation
| IntelliJ | Emacs | Action |
|----------|-------|--------|
| `Cmd+Shift+O` | `Ctrl+Shift+O` | Go to File |
| `Cmd+Alt+O` | `Ctrl+Alt+O` | Go to Symbol |
| `Cmd+L` | `Ctrl+L` | Go to Line |
| `Cmd+E` | `Ctrl+E` | Recent Files |
| `Cmd+B` | `Ctrl+B` | Jump to Definition |
| `Alt+F7` | `Alt+F7` | Find Usages |
| `Cmd+Alt+B` | `Ctrl+Alt+B` | Go to Implementation |

### Editing
| IntelliJ | Emacs | Action |
|----------|-------|--------|
| `Cmd+D` | `Ctrl+D` | Duplicate Line |
| `Cmd+Backspace` | `Ctrl+Backspace` | Delete Line |
| `Alt+Shift+Up` | `Alt+Shift+Up` | Move Line Up |
| `Alt+Shift+Down` | `Alt+Shift+Down` | Move Line Down |
| `Cmd+/` | `Ctrl+/` | Comment/Uncomment |
| `Cmd+Shift+J` | `Ctrl+Shift+J` | Join Lines |

### Code Folding
| IntelliJ | Emacs | Action |
|----------|-------|--------|
| `Cmd+Alt+-` | `Ctrl+Alt+-` | Fold |
| `Cmd+Alt++` | `Ctrl+Alt++` | Unfold |
| `Cmd+Alt+Shift+-` | `Ctrl+Alt+Shift+-` | Fold All |
| `Cmd+Alt+Shift++` | `Ctrl+Alt+Shift++` | Unfold All |

### Refactoring
| IntelliJ | Emacs | Action |
|----------|-------|--------|
| `Shift+F6` | `Shift+F6` | Rename Symbol |
| `Cmd+Alt+M` | `Ctrl+Alt+M` | Extract Method |
| `Cmd+Alt+V` | `Ctrl+Alt+V` | Extract Variable |

### Version Control
| IntelliJ | Emacs | Action |
|----------|-------|--------|
| `Cmd+K` | `Ctrl+K` | Commit |
| `Cmd+Shift+K` | `Ctrl+Shift+K` | Push |
| `Cmd+X G` | `Ctrl+X G` | Git Status |

## Differences from IntelliJ

While this configuration aims to replicate IntelliJ functionality, there are some inherent differences:

1. **Modal Editing**: Emacs uses modal keybindings, while IntelliJ uses direct shortcuts
2. **Project Structure**: Emacs uses projectile, which works differently than IntelliJ's project system
3. **Build System**: Emacs relies on external build tools rather than integrated build systems
4. **UI**: Emacs is text-based, so some visual features differ

## Contributing

To improve this configuration:

1. Test changes thoroughly
2. Document new keybindings
3. Ensure compatibility with existing features
4. Update this README with changes

## License

This configuration is provided as-is for use with Emacs. Individual packages have their own licenses.

## Resources

- [Emacs Manual](https://www.gnu.org/software/emacs/manual/)
- [LSP Mode Documentation](https://emacs-lsp.github.io/lsp-mode/)
- [Projectile Documentation](https://docs.projectile.mx/)
- [Magit Documentation](https://magit.vc/manual/)

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review Emacs and package documentation
3. Search for similar issues online
4. Consider asking in Emacs communities (r/emacs, #emacs on IRC, etc.)

---

**Note**: This configuration is optimized for developers familiar with IntelliJ IDEA. If you're new to Emacs, you may want to learn Emacs basics alongside using this configuration.
