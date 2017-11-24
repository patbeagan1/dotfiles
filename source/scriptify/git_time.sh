git_time () 
{ 
    git log --pretty=format:"%h%x09%an%x09%ad%x09%s" --all --since=2.months.ago --author-date-order --author=pbeagan
}
if [[ $0 != "-bash" ]]; then git_time "$@"; fi
