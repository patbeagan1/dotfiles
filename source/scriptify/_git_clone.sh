_git_clone () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "
			--local
			--no-hardlinks
			--shared
			--reference
			--quiet
			--no-checkout
			--bare
			--mirror
			--origin
			--upload-pack
			--template=
			--depth
			--single-branch
			--branch
			--recurse-submodules
			";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_clone "$@"; fi
