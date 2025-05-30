
function envsec() {
  local cmd="$1"
  shift

  # Unfortunately, yq is a snap that has strict permissions, so it cannot see hidden files. 
  # https://forum.snapcraft.io/t/requesting-classic-confinement-for-yq/10559/16
  local config_dir="$HOME/env"
  local config_file="$config_dir/secrets.yaml"

  command -v gpg >/dev/null || { echo "❌ gpg not found."; return 1; }
  command -v yq >/dev/null || { echo "❌ yq (v4+) not found."; return 1; }
  [[ -z "$GPG_IDENTITY" && "$cmd" = add ]] && { echo "❌ GPG_IDENTITY is not set."; return 1; }

  mkdir -p "$config_dir"
  [[ -f "$config_file" ]] || touch "$config_file"

  case "$cmd" in
    add)
      local key="$1"
      shift

      local plain=false
      if [[ "$1" == "--plain" ]]; then
        plain=true
        shift
      fi

      if [[ -z "$key" ]]; then
        echo "Usage: envsec add <KEY> [--plain]"
        return 1
      fi

      read -s "value?Enter value for $key: "
      echo

      local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

      local encoded
      if [[ "$plain" == true ]]; then
        encoded="$value"
      else
        encoded=$(echo "$value" | gpg --encrypt --armor --recipient "$GPG_IDENTITY" --quiet --batch | base64 | tr -d '\n')
      fi

      yq eval --inplace ".\"$key\".value = \"$encoded\"" "$config_file"
      yq eval --inplace ".\"$key\".encrypted = $([[ $plain == true ]] && echo "false" || echo "true")" "$config_file"
      yq eval --inplace ".\"$key\".last_modified = \"$timestamp\"" "$config_file"

      echo "✅ Secret for $key saved. (encrypted: $([[ $plain == true ]] && echo "no" || echo "yes"))"
      ;;
    load)
      for key in $(yq eval 'keys | .[]' "$config_file"); do
        local encrypted=$(yq eval ".\"$key\".encrypted" "$config_file")
        local raw_value=$(yq eval ".\"$key\".value" "$config_file")

        local decrypted
        if [[ "$encrypted" == "true" ]]; then
          decrypted=$(echo "$raw_value" | base64 --decode | gpg --quiet --batch --yes --decrypt 2>/dev/null)
          if [[ $? -ne 0 ]]; then
            echo "⚠️ Failed to decrypt $key"
            continue
          fi
        else
          decrypted="$raw_value"
        fi

        export "$key=$decrypted"
      done
      echo "✅ Secrets loaded into environment."
      ;;
    list)
      echo "🔐 Stored keys:"
      yq eval 'keys | .[]' "$config_file"
      ;;
    delete)
      local key="$1"
      if [[ -z "$key" ]]; then
        echo "Usage: envsec delete <KEY>"
        return 1
      fi
      if ! yq eval "has(\"$key\")" "$config_file" | grep -q true; then
        echo "❌ $key not found."
        return 1
      fi
      yq eval --inplace "del(.\"$key\")" "$config_file"
      echo "🗑️ Deleted $key."
      ;;
    help|--help|-h|"")
      echo "🔐 Usage: envsec <command> [args...]"
      echo ""
      echo "Commands:"
      echo "  add <KEY> [--plain]   Add or update a secret (default encrypted)"
      echo "  load                  Export secrets into current shell"
      echo "  list                  List stored secret keys"
      echo "  delete <KEY>          Remove a key from the store"
      echo "  help                  Show this help message"
      ;;
    *)
      echo "❌ Unknown command: $cmd"
      envsec help
      return 1
      ;;
  esac
}
