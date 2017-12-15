_git_send_email () 
{ 
    case "$prev" in 
        --to | --cc | --bcc | --from)
            __gitcomp "
		$(git --git-dir="$(__gitdir)" send-email --dump-aliases 2>/dev/null)
		";
            return
        ;;
    esac;
    case "$cur" in 
        --confirm=*)
            __gitcomp "
			$__git_send_email_confirm_options
			" "" "${cur##--confirm=}";
            return
        ;;
        --suppress-cc=*)
            __gitcomp "
			$__git_send_email_suppresscc_options
			" "" "${cur##--suppress-cc=}";
            return
        ;;
        --smtp-encryption=*)
            __gitcomp "ssl tls" "" "${cur##--smtp-encryption=}";
            return
        ;;
        --thread=*)
            __gitcomp "
			deep shallow
			" "" "${cur##--thread=}";
            return
        ;;
        --to=* | --cc=* | --bcc=* | --from=*)
            __gitcomp "
		$(git --git-dir="$(__gitdir)" send-email --dump-aliases 2>/dev/null)
		" "" "${cur#--*=}";
            return
        ;;
        --*)
            __gitcomp "--annotate --bcc --cc --cc-cmd --chain-reply-to
			--compose --confirm= --dry-run --envelope-sender
			--from --identity
			--in-reply-to --no-chain-reply-to --no-signed-off-by-cc
			--no-suppress-from --no-thread --quiet
			--signed-off-by-cc --smtp-pass --smtp-server
			--smtp-server-port --smtp-encryption= --smtp-user
			--subject --suppress-cc= --suppress-from --thread --to
			--validate --no-validate
			$__git_format_patch_options";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then _git_send_email "$@"; fi
