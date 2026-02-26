# Alias files

Any `*.zsh` file here is loaded automatically. The **filename prefix** controls when the file is sourced (like preprocessor defines in C).

Set `LIBBEAGAN_ALIAS_DEBUG` (e.g. `export LIBBEAGAN_ALIAS_DEBUG=1`) to print each alias file name as it is loaded.

| Prefix             | Condition                          |
|--------------------|------------------------------------|
| `alias_`           | Always loaded                      |
| `aliasmac_`        | Only on macOS (`is-test system os mac`) |
| `aliaslinux_`       | Only on Linux                      |
| `aliasinteractive_` | Only in interactive shells         |
| `aliaslogin_`       | Only in login shells               |
| `aliasdebug_`       | Only when `DEBUG` is set            |
| `aliasroot_`        | Only when running as root (EUID 0) |

Files whose names do not start with one of these prefixes are ignored.

Examples: `alias_git.zsh`, `aliasmac_machine.zsh`, `aliaslinux_machine.zsh`, `aliasdebug_dev.zsh`.
