_git_config () 
{ 
    case "$prev" in 
        branch.*.remote | branch.*.pushremote)
            __gitcomp_nl "$(__git_remotes)";
            return
        ;;
        branch.*.merge)
            __gitcomp_nl "$(__git_refs)";
            return
        ;;
        branch.*.rebase)
            __gitcomp "false true preserve interactive";
            return
        ;;
        remote.pushdefault)
            __gitcomp_nl "$(__git_remotes)";
            return
        ;;
        remote.*.fetch)
            local remote="${prev#remote.}";
            remote="${remote%.fetch}";
            if [ -z "$cur" ]; then
                __gitcomp_nl "refs/heads/" "" "" "";
                return;
            fi;
            __gitcomp_nl "$(__git_refs_remotes "$remote")";
            return
        ;;
        remote.*.push)
            local remote="${prev#remote.}";
            remote="${remote%.push}";
            __gitcomp_nl "$(git --git-dir="$(__gitdir)" 			for-each-ref --format='%(refname):%(refname)' 			refs/heads)";
            return
        ;;
        pull.twohead | pull.octopus)
            __git_compute_merge_strategies;
            __gitcomp "$__git_merge_strategies";
            return
        ;;
        color.branch | color.diff | color.interactive | color.showbranch | color.status | color.ui)
            __gitcomp "always never auto";
            return
        ;;
        color.pager)
            __gitcomp "false true";
            return
        ;;
        color.*.*)
            __gitcomp "
			normal black red green yellow blue magenta cyan white
			bold dim ul blink reverse
			";
            return
        ;;
        diff.submodule)
            __gitcomp "log short";
            return
        ;;
        help.format)
            __gitcomp "man info web html";
            return
        ;;
        log.date)
            __gitcomp "$__git_log_date_formats";
            return
        ;;
        sendemail.aliasesfiletype)
            __gitcomp "mutt mailrc pine elm gnus";
            return
        ;;
        sendemail.confirm)
            __gitcomp "$__git_send_email_confirm_options";
            return
        ;;
        sendemail.suppresscc)
            __gitcomp "$__git_send_email_suppresscc_options";
            return
        ;;
        sendemail.transferencoding)
            __gitcomp "7bit 8bit quoted-printable base64";
            return
        ;;
        --get | --get-all | --unset | --unset-all)
            __gitcomp_nl "$(__git_config_get_set_variables)";
            return
        ;;
        *.*)
            return
        ;;
    esac;
    case "$cur" in 
        --*)
            __gitcomp "
			--system --global --local --file=
			--list --replace-all
			--get --get-all --get-regexp
			--add --unset --unset-all
			--remove-section --rename-section
			--name-only
			";
            return
        ;;
        branch.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "remote pushremote merge mergeoptions rebase" "$pfx" "$cur_";
            return
        ;;
        branch.*)
            local pfx="${cur%.*}." cur_="${cur#*.}";
            __gitcomp_nl "$(__git_heads)" "$pfx" "$cur_" ".";
            __gitcomp_nl_append 'autosetupmerge
autosetuprebase
' "$pfx" "$cur_";
            return
        ;;
        guitool.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "
			argprompt cmd confirm needsfile noconsole norescan
			prompt revprompt revunmerged title
			" "$pfx" "$cur_";
            return
        ;;
        difftool.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "cmd path" "$pfx" "$cur_";
            return
        ;;
        man.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "cmd path" "$pfx" "$cur_";
            return
        ;;
        mergetool.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "cmd path trustExitCode" "$pfx" "$cur_";
            return
        ;;
        pager.*)
            local pfx="${cur%.*}." cur_="${cur#*.}";
            __git_compute_all_commands;
            __gitcomp_nl "$__git_all_commands" "$pfx" "$cur_";
            return
        ;;
        remote.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "
			url proxy fetch push mirror skipDefaultUpdate
			receivepack uploadpack tagopt pushurl
			" "$pfx" "$cur_";
            return
        ;;
        remote.*)
            local pfx="${cur%.*}." cur_="${cur#*.}";
            __gitcomp_nl "$(__git_remotes)" "$pfx" "$cur_" ".";
            __gitcomp_nl_append "pushdefault" "$pfx" "$cur_";
            return
        ;;
        url.*.*)
            local pfx="${cur%.*}." cur_="${cur##*.}";
            __gitcomp "insteadOf pushInsteadOf" "$pfx" "$cur_";
            return
        ;;
    esac;
    __gitcomp "
		add.ignoreErrors
		advice.commitBeforeMerge
		advice.detachedHead
		advice.implicitIdentity
		advice.pushNonFastForward
		advice.resolveConflict
		advice.statusHints
		alias.
		am.keepcr
		apply.ignorewhitespace
		apply.whitespace
		branch.autosetupmerge
		branch.autosetuprebase
		browser.
		clean.requireForce
		color.branch
		color.branch.current
		color.branch.local
		color.branch.plain
		color.branch.remote
		color.decorate.HEAD
		color.decorate.branch
		color.decorate.remoteBranch
		color.decorate.stash
		color.decorate.tag
		color.diff
		color.diff.commit
		color.diff.frag
		color.diff.func
		color.diff.meta
		color.diff.new
		color.diff.old
		color.diff.plain
		color.diff.whitespace
		color.grep
		color.grep.context
		color.grep.filename
		color.grep.function
		color.grep.linenumber
		color.grep.match
		color.grep.selected
		color.grep.separator
		color.interactive
		color.interactive.error
		color.interactive.header
		color.interactive.help
		color.interactive.prompt
		color.pager
		color.showbranch
		color.status
		color.status.added
		color.status.changed
		color.status.header
		color.status.nobranch
		color.status.unmerged
		color.status.untracked
		color.status.updated
		color.ui
		commit.status
		commit.template
		core.abbrev
		core.askpass
		core.attributesfile
		core.autocrlf
		core.bare
		core.bigFileThreshold
		core.compression
		core.createObject
		core.deltaBaseCacheLimit
		core.editor
		core.eol
		core.excludesfile
		core.fileMode
		core.fsyncobjectfiles
		core.gitProxy
		core.ignoreStat
		core.ignorecase
		core.logAllRefUpdates
		core.loosecompression
		core.notesRef
		core.packedGitLimit
		core.packedGitWindowSize
		core.pager
		core.preferSymlinkRefs
		core.preloadindex
		core.quotepath
		core.repositoryFormatVersion
		core.safecrlf
		core.sharedRepository
		core.sparseCheckout
		core.symlinks
		core.trustctime
		core.untrackedCache
		core.warnAmbiguousRefs
		core.whitespace
		core.worktree
		diff.autorefreshindex
		diff.external
		diff.ignoreSubmodules
		diff.mnemonicprefix
		diff.noprefix
		diff.renameLimit
		diff.renames
		diff.statGraphWidth
		diff.submodule
		diff.suppressBlankEmpty
		diff.tool
		diff.wordRegex
		diff.algorithm
		difftool.
		difftool.prompt
		fetch.recurseSubmodules
		fetch.unpackLimit
		format.attach
		format.cc
		format.coverLetter
		format.from
		format.headers
		format.numbered
		format.pretty
		format.signature
		format.signoff
		format.subjectprefix
		format.suffix
		format.thread
		format.to
		gc.
		gc.aggressiveWindow
		gc.auto
		gc.autopacklimit
		gc.packrefs
		gc.pruneexpire
		gc.reflogexpire
		gc.reflogexpireunreachable
		gc.rerereresolved
		gc.rerereunresolved
		gitcvs.allbinary
		gitcvs.commitmsgannotation
		gitcvs.dbTableNamePrefix
		gitcvs.dbdriver
		gitcvs.dbname
		gitcvs.dbpass
		gitcvs.dbuser
		gitcvs.enabled
		gitcvs.logfile
		gitcvs.usecrlfattr
		guitool.
		gui.blamehistoryctx
		gui.commitmsgwidth
		gui.copyblamethreshold
		gui.diffcontext
		gui.encoding
		gui.fastcopyblame
		gui.matchtrackingbranch
		gui.newbranchtemplate
		gui.pruneduringfetch
		gui.spellingdictionary
		gui.trustmtime
		help.autocorrect
		help.browser
		help.format
		http.lowSpeedLimit
		http.lowSpeedTime
		http.maxRequests
		http.minSessions
		http.noEPSV
		http.postBuffer
		http.proxy
		http.sslCipherList
		http.sslVersion
		http.sslCAInfo
		http.sslCAPath
		http.sslCert
		http.sslCertPasswordProtected
		http.sslKey
		http.sslVerify
		http.useragent
		i18n.commitEncoding
		i18n.logOutputEncoding
		imap.authMethod
		imap.folder
		imap.host
		imap.pass
		imap.port
		imap.preformattedHTML
		imap.sslverify
		imap.tunnel
		imap.user
		init.templatedir
		instaweb.browser
		instaweb.httpd
		instaweb.local
		instaweb.modulepath
		instaweb.port
		interactive.singlekey
		log.date
		log.decorate
		log.showroot
		mailmap.file
		man.
		man.viewer
		merge.
		merge.conflictstyle
		merge.log
		merge.renameLimit
		merge.renormalize
		merge.stat
		merge.tool
		merge.verbosity
		mergetool.
		mergetool.keepBackup
		mergetool.keepTemporaries
		mergetool.prompt
		notes.displayRef
		notes.rewrite.
		notes.rewrite.amend
		notes.rewrite.rebase
		notes.rewriteMode
		notes.rewriteRef
		pack.compression
		pack.deltaCacheLimit
		pack.deltaCacheSize
		pack.depth
		pack.indexVersion
		pack.packSizeLimit
		pack.threads
		pack.window
		pack.windowMemory
		pager.
		pretty.
		pull.octopus
		pull.twohead
		push.default
		push.followTags
		rebase.autosquash
		rebase.stat
		receive.autogc
		receive.denyCurrentBranch
		receive.denyDeleteCurrent
		receive.denyDeletes
		receive.denyNonFastForwards
		receive.fsckObjects
		receive.unpackLimit
		receive.updateserverinfo
		remote.pushdefault
		remotes.
		repack.usedeltabaseoffset
		rerere.autoupdate
		rerere.enabled
		sendemail.
		sendemail.aliasesfile
		sendemail.aliasfiletype
		sendemail.bcc
		sendemail.cc
		sendemail.cccmd
		sendemail.chainreplyto
		sendemail.confirm
		sendemail.envelopesender
		sendemail.from
		sendemail.identity
		sendemail.multiedit
		sendemail.signedoffbycc
		sendemail.smtpdomain
		sendemail.smtpencryption
		sendemail.smtppass
		sendemail.smtpserver
		sendemail.smtpserveroption
		sendemail.smtpserverport
		sendemail.smtpuser
		sendemail.suppresscc
		sendemail.suppressfrom
		sendemail.thread
		sendemail.to
		sendemail.validate
		showbranch.default
		status.relativePaths
		status.showUntrackedFiles
		status.submodulesummary
		submodule.
		tar.umask
		transfer.unpackLimit
		url.
		user.email
		user.name
		user.signingkey
		web.browser
		branch. remote.
	"
}
if [[ $0 != "-bash" ]]; then _git_config "$@"; fi
