###########################################################
# extract / x — unpack common archives (no Oh My Zsh)
###########################################################

alias x=extract

extract() {
  setopt localoptions noautopushd

  if (( $# == 0 )); then
    cat >&2 <<'EOF'
Usage: extract [-option] [file ...]

Options:
    -r, --remove    Remove archive after unpacking.
    -t, --to-directory <dir>  Extract to a specific directory.
EOF
    return 1
  fi

  local remove_archive=1
  local target_directory=""

  while (( $# > 0 )); do
    case "$1" in
      -r|--remove)
        remove_archive=0
        shift
        ;;
      -t|--to-directory)
        shift
        if (( $# == 0 )); then
          print -u2 "extract: -t/--to-directory requires a directory argument"
          return 1
        fi
        target_directory="${1%/}"
        shift
        if [[ ! -d "$target_directory" ]]; then
          print -u2 "extract: '$target_directory' is not a valid directory"
          return 1
        fi
        ;;
      *)
        break
        ;;
    esac
  done

  local pwd="$PWD"
  while (( $# > 0 )); do
    if [[ ! -f "$1" ]]; then
      print -u2 "extract: '$1' is not a valid file"
      shift
      continue
    fi

    local success=0
    local file="$1" full_path="${1:A}"
    local extract_dir="${1:t:r}"

    if [[ $extract_dir =~ '\.tar$' ]]; then
      extract_dir="${extract_dir:r}"
    fi
    if [[ -n "$target_directory" ]]; then
      extract_dir="$target_directory/${extract_dir:t}"
    fi
    if [[ -e "$extract_dir" ]]; then
      local rnd="${(L)"${$(( [##36]$RANDOM*$RANDOM ))}":1:5}"
      extract_dir="${extract_dir}-${rnd}"
    fi

    command mkdir -p "$extract_dir"
    builtin cd -q "$extract_dir"
    print -u2 "extract: extracting to $extract_dir"

    case "${file:l}" in
      (*.tar.gz|*.tgz) tar zxvf "$full_path" ;;
      (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$full_path" ;;
      (*.tar.xz|*.txz)
        tar --xz -xvf "$full_path" 2>/dev/null || xzcat "$full_path" | tar xvf - ;;
      (*.tar.zst|*.tzst)
        tar --zstd -xvf "$full_path" 2>/dev/null || zstdcat "$full_path" | tar xvf - ;;
      (*.tar) tar xvf "$full_path" ;;
      (*.gz) gunzip -ck "$full_path" > "${file:t:r}" ;;
      (*.bz2) bunzip2 "$full_path" ;;
      (*.xz) xzcat "$full_path" > "${file:t:r}" ;;
      (*.zip|*.war|*.jar|*.ear|*.apk|*.whl) unzip "$full_path" ;;
      (*.rar)
        if (( $+commands[unrar] )); then
          unrar x -ad "$full_path"
        elif (( $+commands[unar] )); then
          unar -o . "$full_path"
        else
          print -u2 "extract: install unrar or unar for RAR files"
          success=1
        fi
        ;;
      (*.7z) 7za x "$full_path" ;;
      (*.zst) unzstd --stdout "$full_path" > "${file:t:r}" ;;
      (*)
        print -u2 "extract: '$file' cannot be extracted"
        success=1
        ;;
    esac

    (( success = success > 0 ? success : $? ))
    (( success == 0 && remove_archive == 0 )) && command rm "$full_path"
    shift

    builtin cd -q "$pwd"

    local -a content
    content=("${extract_dir}"/*(DNY2))
    if [[ ${#content} -eq 1 && -e "${content[1]}" ]]; then
      if [[ "${content[1]:t}" == "${extract_dir:t}" ]]; then
        local tmp_name==(:); tmp_name="${tmp_name:t}"
        command mv "${content[1]}" "$tmp_name" \
          && command rmdir "$extract_dir" \
          && command mv "$tmp_name" "$extract_dir"
      elif [[ ! -e "${target_directory:-.}/${content[1]:t}" ]]; then
        command mv -- "${content[1]}" "${target_directory:-.}/" \
          && command rmdir -- "$extract_dir"
      fi
    elif [[ ${#content} -eq 0 ]]; then
      command rmdir "$extract_dir"
    fi
  done
}
