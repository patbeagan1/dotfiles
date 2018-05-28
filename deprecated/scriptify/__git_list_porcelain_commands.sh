__git_list_porcelain_commands () 
{ 
    local i IFS=" "'
';
    __git_compute_all_commands;
    for i in $__git_all_commands;
    do
        case $i in 
            *--*)
                : helper pattern
            ;;
            applymbox)
                : ask gittus
            ;;
            applypatch)
                : ask gittus
            ;;
            archimport)
                : import
            ;;
            cat-file)
                : plumbing
            ;;
            check-attr)
                : plumbing
            ;;
            check-ignore)
                : plumbing
            ;;
            check-mailmap)
                : plumbing
            ;;
            check-ref-format)
                : plumbing
            ;;
            checkout-index)
                : plumbing
            ;;
            column)
                : internal helper
            ;;
            commit-tree)
                : plumbing
            ;;
            count-objects)
                : infrequent
            ;;
            credential)
                : credentials
            ;;
            credential-*)
                : credentials helper
            ;;
            cvsexportcommit)
                : export
            ;;
            cvsimport)
                : import
            ;;
            cvsserver)
                : daemon
            ;;
            daemon)
                : daemon
            ;;
            diff-files)
                : plumbing
            ;;
            diff-index)
                : plumbing
            ;;
            diff-tree)
                : plumbing
            ;;
            fast-import)
                : import
            ;;
            fast-export)
                : export
            ;;
            fsck-objects)
                : plumbing
            ;;
            fetch-pack)
                : plumbing
            ;;
            fmt-merge-msg)
                : plumbing
            ;;
            for-each-ref)
                : plumbing
            ;;
            hash-object)
                : plumbing
            ;;
            http-*)
                : transport
            ;;
            index-pack)
                : plumbing
            ;;
            init-db)
                : deprecated
            ;;
            local-fetch)
                : plumbing
            ;;
            ls-files)
                : plumbing
            ;;
            ls-remote)
                : plumbing
            ;;
            ls-tree)
                : plumbing
            ;;
            mailinfo)
                : plumbing
            ;;
            mailsplit)
                : plumbing
            ;;
            merge-*)
                : plumbing
            ;;
            mktree)
                : plumbing
            ;;
            mktag)
                : plumbing
            ;;
            pack-objects)
                : plumbing
            ;;
            pack-redundant)
                : plumbing
            ;;
            pack-refs)
                : plumbing
            ;;
            parse-remote)
                : plumbing
            ;;
            patch-id)
                : plumbing
            ;;
            prune)
                : plumbing
            ;;
            prune-packed)
                : plumbing
            ;;
            quiltimport)
                : import
            ;;
            read-tree)
                : plumbing
            ;;
            receive-pack)
                : plumbing
            ;;
            remote-*)
                : transport
            ;;
            rerere)
                : plumbing
            ;;
            rev-list)
                : plumbing
            ;;
            rev-parse)
                : plumbing
            ;;
            runstatus)
                : plumbing
            ;;
            sh-setup)
                : internal
            ;;
            shell)
                : daemon
            ;;
            show-ref)
                : plumbing
            ;;
            send-pack)
                : plumbing
            ;;
            show-index)
                : plumbing
            ;;
            ssh-*)
                : transport
            ;;
            stripspace)
                : plumbing
            ;;
            symbolic-ref)
                : plumbing
            ;;
            unpack-file)
                : plumbing
            ;;
            unpack-objects)
                : plumbing
            ;;
            update-index)
                : plumbing
            ;;
            update-ref)
                : plumbing
            ;;
            update-server-info)
                : daemon
            ;;
            upload-archive)
                : plumbing
            ;;
            upload-pack)
                : plumbing
            ;;
            write-tree)
                : plumbing
            ;;
            var)
                : infrequent
            ;;
            verify-pack)
                : infrequent
            ;;
            verify-tag)
                : plumbing
            ;;
            *)
                echo $i
            ;;
        esac;
    done
}
if [[ $0 != "-bash" ]]; then __git_list_porcelain_commands "$@"; fi
