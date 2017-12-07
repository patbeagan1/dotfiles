_git_svn () 
{ 
    local subcommands="
		init fetch clone rebase dcommit log find-rev
		set-tree commit-diff info create-ignore propget
		proplist show-ignore show-externals branch tag blame
		migrate mkdirs reset gc
		";
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands";
    else
        local remote_opts="--username= --config-dir= --no-auth-cache";
        local fc_opts="
			--follow-parent --authors-file= --repack=
			--no-metadata --use-svm-props --use-svnsync-props
			--log-window-size= --no-checkout --quiet
			--repack-flags --use-log-author --localtime
			--ignore-paths= --include-paths= $remote_opts
			";
        local init_opts="
			--template= --shared= --trunk= --tags=
			--branches= --stdlayout --minimize-url
			--no-metadata --use-svm-props --use-svnsync-props
			--rewrite-root= --prefix= --use-log-author
			--add-author-from $remote_opts
			";
        local cmt_opts="
			--edit --rmdir --find-copies-harder --copy-similarity=
			";
        case "$subcommand,$cur" in 
            fetch,--*)
                __gitcomp "--revision= --fetch-all $fc_opts"
            ;;
            clone,--*)
                __gitcomp "--revision= $fc_opts $init_opts"
            ;;
            init,--*)
                __gitcomp "$init_opts"
            ;;
            dcommit,--*)
                __gitcomp "
				--merge --strategy= --verbose --dry-run
				--fetch-all --no-rebase --commit-url
				--revision --interactive $cmt_opts $fc_opts
				"
            ;;
            set-tree,--*)
                __gitcomp "--stdin $cmt_opts $fc_opts"
            ;;
            create-ignore,--* | propget,--* | proplist,--* | show-ignore,--* | show-externals,--* | mkdirs,--*)
                __gitcomp "--revision="
            ;;
            log,--*)
                __gitcomp "
				--limit= --revision= --verbose --incremental
				--oneline --show-commit --non-recursive
				--authors-file= --color
				"
            ;;
            rebase,--*)
                __gitcomp "
				--merge --verbose --strategy= --local
				--fetch-all --dry-run $fc_opts
				"
            ;;
            commit-diff,--*)
                __gitcomp "--message= --file= --revision= $cmt_opts"
            ;;
            info,--*)
                __gitcomp "--url"
            ;;
            branch,--*)
                __gitcomp "--dry-run --message --tag"
            ;;
            tag,--*)
                __gitcomp "--dry-run --message"
            ;;
            blame,--*)
                __gitcomp "--git-format"
            ;;
            migrate,--*)
                __gitcomp "
				--config-dir= --ignore-paths= --minimize
				--no-auth-cache --username=
				"
            ;;
            reset,--*)
                __gitcomp "--revision= --parent"
            ;;
            *)

            ;;
        esac;
    fi
}
if [[ $0 != "-bash" ]]; then _git_svn "$@"; fi
