
function envsec() {
  local cmd="$1"
  shift

  # Unfortunately, yq is a snap that has strict permissions, so it cannot see hidden files. 
  # https://forum.snapcraft.io/t/requesting-classic-confinement-for-yq/10559/16
  local config_file="$HOME/env/secrets.yaml"

  command -v gpg >/dev/null || { echo "❌ gpg not found."; return 1; }
  command -v yq >/dev/null || { echo "❌ yq (v4+) not found."; return 1; }
  command -v pbcopy >/dev/null 2>/dev/null || command -v xclip >/dev/null 2>/dev/null || {
    [[ "$1" == "copy" ]] && echo "❌ No clipboard tool found (requires pbcopy or xclip)."
  }

  local gpg_id_override=""
  for arg in "$@"; do
    if [[ "$arg" == "--gpg-id" ]]; then
      gpg_id_override="next"
    elif [[ "$gpg_id_override" == "next" ]]; then
      GPG_IDENTITY="$arg"
      gpg_id_override=""
    fi
  done

  [[ -z "$GPG_IDENTITY" && "$cmd" = add ]] && { echo "❌ GPG_IDENTITY is not set."; return 1; }

  local secrets_file_override=""
  for arg in "$@"; do
    if [[ "$arg" == "--file" ]]; then
      secrets_file_override="next"
    elif [[ "$secrets_file_override" == "next" ]]; then
      config_file="$arg"
      secrets_file_override=""
    fi
  done

  mkdir -p "$(dirname "$config_file")"
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
      echo "🔐 Stored secrets:"
      yq eval 'to_entries[] |
        with(select(.value.encrypted == true); .value.format = "🔒") |  
        with(select(.value.encrypted == false); .value.format = "📖") |  
        "(\(.value.last_modified)) \(.value.format) \(.key)"' "$config_file"  
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

      if [[ -z "$value" ]] || [[ null = "$value" ]]; then
        echo "❌ Key $key is not set, or is empty."
        return 1
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
    ingest)
      local key="$1"
      shift

      local plain=false
      if [[ "$1" == "--plain" ]]; then
        plain=true
        shift
      fi

      if [[ -z "$key" ]]; then
        echo "Usage: envsec ingest <ENV_VAR_NAME> [--plain]"
        return 1
      fi

      local value="${(P)key}"  # Get value of the env var
      if [[ -z "$value" ]]; then
        echo "❌ Environment variable $key not set or empty."
        return 1
      fi

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

      echo "✅ Ingested $key from environment. (encrypted: $([[ $plain == true ]] && echo "no" || echo "yes"))"
      ;;
    genkey)
      echo "🔧 Generating a new GPG key using GPG's built-in interactive tool."
      echo "💡 You will be prompted to enter your name, email, and passphrase."
      echo ""

      gpg --full-generate-key

      echo
      echo "🔍 Retrieving the latest key you generated..."

      local last_fpr
      last_fpr=$(gpg --list-keys --with-colons | awk -F: '/^fpr:/ {print $10}' | tail -n1)

      if [[ -z "$last_fpr" ]]; then
        echo "❌ Failed to retrieve GPG key fingerprint."
        return 1
      fi

      local email
      email=$(gpg --list-keys "$last_fpr" | awk -F' ' '/^uid/ { print $0 }' | sed 's/.*<//' | sed 's/>.*//')

      echo ""
      echo "✅ GPG key created."
      echo "🔑 Fingerprint: $last_fpr"
      echo "📧 Email: $email"

      read -q "?💡 Set this as your default GPG_IDENTITY for envsec? [y/N] " confirm
      echo
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        export GPG_IDENTITY="$email"
        echo "✅ GPG_IDENTITY set to: $email"
        echo 'export GPG_IDENTITY="'"$email"'"' >> ~/.zshrc
      fi
      ;;
    migrate-key)
      local new_identity="$1"
      shift

      local force=false
      for arg in "$@"; do
        [[ "$arg" == "--force" ]] && force=true
      done

      if [[ -z "$new_identity" ]]; then
        echo "Usage: envsec migrate-key <NEW_GPG_IDENTITY> [--file <FILE>] [--dry-run]"
        return 1
      fi

      echo "🔄 Migrating encrypted secrets to new GPG key: $new_identity"
      [[ "$force" == false ]] && echo "🧪 Dry run mode — no changes will be saved."

      local updated=false
      local backup_file="${config_file}.bak.$(date +%Y%m%d%H%M%S)"

      local keys_json=$(yq eval -o=json '.' "$config_file")

      for key in $(echo "$keys_json" | jq -r 'keys[]'); do
        local is_encrypted=$(echo "$keys_json" | jq -r --arg key "$key" '.[$key].encrypted')
        if [[ "$is_encrypted" != "true" ]]; then
          continue
        fi

        local encoded=$(echo "$keys_json" | jq -r --arg key "$key" '.[$key].value')
        local decrypted=$(echo "$encoded" | base64 --decode | gpg --quiet --batch --yes --decrypt 2>/dev/null)

        if [[ -z "$decrypted" ]]; then
          echo "❌ Failed to decrypt $key. Skipping."
          continue
        fi

        if [[ "$force" == false ]]; then
          echo "🔍 Would migrate: $key"
          continue
        fi

        local re_encrypted=$(echo "$decrypted" | gpg --encrypt --armor --recipient "$new_identity" --quiet --batch | base64 | tr -d '\n')
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        # Create backup once before modifying anything
        if [[ "$updated" == false ]]; then
          cp "$config_file" "$backup_file"
          echo "💾 Backup created at $backup_file"
        fi

        # Update YAML
        yq eval --inplace ".\"$key\".value = \"$re_encrypted\"" "$config_file"
        yq eval --inplace ".\"$key\".last_modified = \"$timestamp\"" "$config_file"

        echo "🔐 Migrated $key"
        updated=true
      done

      if [[ "$force" == false ]]; then
        echo "✅ Dry run complete. No changes were written."
      elif [[ "$updated" == true ]]; then
        echo "✅ Migration complete."
      else
        echo "ℹ️ No keys were migrated."
      fi
      ;;


    help|--help|-h|"")
      echo "🔐 Usage: envsec <command> [args...]"
      echo ""
      echo "Options:"
      echo "  --file <file>     Use alternate secrets file (default: ~/env/secrets.yaml)"
      echo ""
      echo "Commands:"
      echo "  load                     Export all secrets into environment"
      echo "  list                     List all stored secret keys"
      echo "  add <KEY> [--plain]      Add or update a secret (encrypted by default)"
      echo "  copy <KEY>               Copy decrypted secret to clipboard"
      echo "  delete <KEY>             Remove a key from the store"
      echo "  encrypt <KEY>            Encrypt an existing plaintext secret"
      echo "  ingest <KEY> [--plain]   Import from current shell env var"
      echo "  genkey                   Create a new GPG key pair (uses interactive GPG flow)"
      echo "  migrate-key <GPG ID> [--force]"
      echo "                           Migrates encrypted values in a file from one key to another."
      echo "                             Creates a backup"
      echo "                             Does a dry run if used without --force"
      echo "  help                     Show this help message"
      ;;
    *)
      echo "❌ Unknown command: $cmd"
      envsec help
      return 1
      ;;
  esac
}
