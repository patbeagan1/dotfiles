install_intellij_to_xcode_keybindings() {
  # Ensure we are on a Mac
  if [[ "$OSTYPE" != darwin* ]]; then
    echo "This script can only be run on macOS."
    return 1
  fi

  local src_dir="$(cd "$(dirname "${(%):-%N}")" && pwd)"
  local keybindings_file="${src_dir}/IntelliJ_to_Xcode.idekeybindings"
  local dest_dir="$HOME/Library/Developer/Xcode/UserData/KeyBindings"
  local dest_file="${dest_dir}/IntelliJ_to_Xcode.idekeybindings"

  if [[ ! -f "$keybindings_file" ]]; then
    echo "Keybindings file not found: $keybindings_file"
    return 1
  fi

  mkdir -p "$dest_dir"
  cp "$keybindings_file" "$dest_file"
  echo "Installed IntelliJ_to_Xcode.idekeybindings to $dest_file"
}
