
function envsec() {
  local cmd="$1"
  shift

  # Unfortunately, yq is a snap that has strict permissions, so it cannot see hidden files. 
  # https://forum.snapcraft.io/t/requesting-classic-confinement-for-yq/10559/16
  local config_dir="$HOME/env"
  local config_file="$config_dir/secrets.yaml"

  command -v gpg >/dev/null || { echo "❌ gpg not found."; return 1; }
  command -v yq >/dev/null || { echo "❌ yq (v4+) not found."; return 1; }
  command -v pbcopy >/dev/null 2>/dev/null || command -v xclip >/dev/null 2>/dev/null || {
    [[ "$1" == "copy" ]] && echo "❌ No clipboard tool found (requires pbcopy or xclip)."
  }
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
      local decrypted
      for key in $(yq eval 'keys | .[]' "$config_file"); do
        local encrypted=$(yq eval ".\"$key\".encrypted" "$config_file")
        local raw_value=$(yq eval ".\"$key\".value" "$config_file")

        if [[ "$encrypted" == "true" ]]; then
          decrypted="$(echo "$raw_value" | base64 --decode | gpg --quiet --batch --yes --decrypt 2>/dev/null)"
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
    encrypt)
      local key="$1"
      if [[ -z "$key" ]]; then
        echo "Usage: envsec encrypt <KEY>"
        return 1
      fi
      if [[ "$(yq eval ".\"$key\".encrypted" "$config_file")" != "false" ]]; then
        echo "🔒 $key is already encrypted or does not exist."
        return 1
      fi

      local plain_value=$(yq eval ".\"$key\".value" "$config_file")
      local encrypted_value=$(echo "$plain_value" | gpg --encrypt --armor --recipient "$GPG_IDENTITY" --quiet --batch | base64 | tr -d '\n')
      local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

      yq eval --inplace ".\"$key\".value = \"$encrypted_value\"" "$config_file"
      yq eval --inplace ".\"$key\".encrypted = true" "$config_file"
      yq eval --inplace ".\"$key\".last_modified = \"$timestamp\"" "$config_file"

      echo "🔐 $key has been encrypted."
      ;;
    copy)
      local key="$1"
      if [[ -z "$key" ]]; then
        echo "Usage: envsec copy <KEY>"
        return 1
      fi

      local encrypted=$(yq eval ".\"$key\".encrypted" "$config_file")
      local raw_value=$(yq eval ".\"$key\".value" "$config_file")
      local value

      if [[ "$encrypted" == "true" ]]; then
        value=$(echo "$raw_value" | base64 --decode | gpg --quiet --batch --yes --decrypt 2>/dev/null)
        [[ $? -ne 0 ]] && { echo "❌ Failed to decrypt $key"; return 1; }
      else
        value="$raw_value"
      fi

      if command -v pbcopy &>/dev/null; then
        echo -n "$value" | pbcopy
      elif command -v xclip &>/dev/null; then
        echo -n "$value" | xclip -selection clipboard
      else
        echo "❌ No clipboard tool found (pbcopy or xclip required)"
        return 1
      fi

      echo "📋 $key copied to clipboard."
      ;;
    help|--help|-h|"")
      echo "🔐 Usage: envsec <command> [args...]"
      echo ""
      echo "Commands:"
      echo "  add <KEY> [--plain]   Add or update a secret (encrypted by default)"
      echo "  encrypt <KEY>         Encrypt an existing plaintext secret"
      echo "  copy <KEY>            Copy decrypted secret to clipboard"
      echo "  load                  Export all secrets into environment"
      echo "  list                  List all stored secret keys"
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
