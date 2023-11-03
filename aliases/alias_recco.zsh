# General Shortcuts
alias ll='ls -lAh'  # Detailed list view
alias la='ls -A'    # List all except . and ..
alias l='ls -CF'    # List in columns

# Git Aliases
alias gs='git status'
alias gl='git log'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gp='git push'
alias gcl='git clone'
alias gbr='git branch'
alias gm='git merge'
alias grm='git rm'

# Vim
alias v='vim'
alias nv='nvim'  # If you have neovim installed

# Docker
alias dps='docker ps'
alias dexec='docker exec -it'
alias dlogs='docker logs'
alias drm='docker rm'
alias drmi='docker rmi'
alias dcup='docker-compose up'
alias dcdown='docker-compose down'

# Kubernetes
alias k='kubectl'
alias kget='kubectl get'
alias kdesc='kubectl describe'
alias kdel='kubectl delete'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'

# Tmux
alias ta='tmux attach -t'
alias tls='tmux list-sessions'
alias tnew='tmux new-session -s'

# Others
alias tf='terraform'
alias grep='grep --color=auto'  # Color output for grep


# Terraform
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

# Ansible
alias apb='ansible-playbook'

# Networking
alias pingg='ping 8.8.8.8'  # Google's DNS for quick network check
alias ns='netstat -tuln'   # Network stats
alias myip='curl ifconfig.me'  # Get public IP

# Sed & Awk
alias sedi='sed -i "" '  # In-place edit with sed for macOS (omit the "" for Linux)
alias awkf='awk -F'  # Specify field separator

# Directories and Files
alias rmf='rm -rf'  # Be very careful with this one!
alias mkdirp='mkdir -p'

# System
alias topmem='top -o %MEM'  # Top processes by memory
alias topcpu='top -o %CPU'  # Top processes by CPU usage
alias dfh='df -h'  # Disk space in human-readable format
alias duh='du -sh'  # Directory size in human-readable format

# Search
alias agi='ag --ignore-case'  # Case insensitive search with Silver Searcher

# Misc
alias reload='source ~/.zshrc'  # Or ~/.bashrc depending on your shell
alias path='echo $PATH | tr ":" "\n"'  # Print PATH entries line by line

# Git Enhancements
alias gundo='git reset HEAD~'  # Undo last commit
alias gstash='git stash'
alias gstashp='git stash pop'
alias greb='git rebase'

# Docker Enhancements
alias dprune='docker system prune -a'  # Prune unused docker images, containers, etc.
alias dstopall='docker stop $(docker ps -aq)'  # Stop all running containers

# Kubernetes Enhancements
alias kctx='kubectl config current-context'  # Get current context
alias kctxs='kubectl config get-contexts'  # List contexts
alias kns='kubectl config set-context --current --namespace'  # Change namespace in current context

# Process Management
alias psg='ps aux | grep'  # Search in running processes

# Resource Monitoring
alias freeh='free -h'  # Memory usage in human-readable format
alias iotop='iotop -oP'  # Monitor IO usage

# Network Enhancements
alias ifup='sudo ifconfig up'  # Enable network interface (likely you'd append interface name)
alias ifdown='sudo ifconfig down'  # Disable network interface

# Disk Usage
alias largest='du -hs * | sort -rh | head'  # Shows top largest directories/files

# History
alias hgrep='history | grep'  # Search command history

# Others
alias cls='clear'  # Clear screen
alias epoch='date +%s'  # Current epoch time
alias datef='date "+%Y-%m-%d %T"'  # Formatted date
alias ports='lsof -i'  # Check open ports
alias listen='lsof -i | grep LISTEN'  # Check listening ports

# System Recovery and Safety
alias chroot='sudo chroot'  # Change root directory - useful for system recovery
alias fsck='sudo fsck'  # File system consistency check and repair

# SystemD (used for managing services on many Linux distributions)
alias sysstart='sudo systemctl start'  # Start a service
alias sysstop='sudo systemctl stop'   # Stop a service
alias sysenable='sudo systemctl enable'   # Enable a service at boot
alias sysdisable='sudo systemctl disable' # Disable a service at boot
alias syslogs='sudo journalctl -u'  # Check logs for a specific service

# Firewall (UFW - Uncomplicated Firewall)
alias ufwallow='sudo ufw allow'  # Allow traffic on a specific port
alias ufwdeny='sudo ufw deny'    # Deny traffic on a specific port

# User Management (useful for system administrators)
alias useradd='sudo useradd'  # Add a new user
alias userdel='sudo userdel'  # Delete a user
alias passwd='sudo passwd'    # Change user password

# Networking Troubleshooting
alias nslookup='nslookup'  # Query DNS lookup
alias dig='dig'  # DNS lookup utility
alias mtr='sudo mtr'  # Network diagnostic tool

# Disk Management
alias fdiskl='sudo fdisk -l'  # List disk partitions
alias ddrescue='sudo ddrescue'  # Data recovery tool

# Package Management (depends on the distro, here are a few examples)
alias aptupg='sudo apt update && sudo apt upgrade'  # Update and upgrade packages (Debian/Ubuntu)
alias yumupg='sudo yum update'  # Update packages (RedHat/CentOS)

# Cron Jobs
alias crontab='crontab'  # Schedule periodic background tasks
alias cronlog='sudo grep CRON /var/log/syslog'  # View cron logs (Debian/Ubuntu)

# Secure File Transfer
alias scp='scp'  # Securely copy files between hosts over SSH

# Remote System Monitoring
alias nmon='nmon'  # Monitor system resource, requires nmon to be installed

# Database (for MySQL as an example)
alias mysqldump='mysqldump'  # Backup MySQL databases

# Compression and Archives
alias untar='tar -xvf'  # Extract TAR files
alias ungz='gunzip'     # Decompress .gz files

# SystemD (managing services on many Linux distributions)
alias sysr='sudo systemctl restart'  # Restart a service
alias sysstat='sudo systemctl status'  # Status of a service
alias syslogs='journalctl -xe'  # View detailed system logs

# Firewall (UFW - Uncomplicated Firewall)
alias ufwstatus='sudo ufw status verbose'  # Detailed status of firewall rules

# Networking Troubleshooting
alias intf='ip addr show'  # Show network interfaces and their statuses
alias nstat='netstat -tuln'  # Show listening ports and associated processes

# Disk Management
alias partedl='sudo parted -l'  # List disk partitions more detailed than fdisk
alias mountl='mount | column -t'  # List mounted file systems in a readable format

# Package Management (examples for Debian/Ubuntu and RedHat/CentOS)
alias aptclean='sudo apt autoremove && sudo apt clean'  # Clean up unnecessary packages and cached files (Debian/Ubuntu)
alias yumclean='sudo yum clean all'  # Clean cached package data (RedHat/CentOS)

# Cron Jobs
alias cronedit='crontab -e'  # Edit the current user's cron jobs
alias cronlist='crontab -l'  # List the current user's cron jobs

# Compression and Archives
alias tarc='tar -czvf'  # Create a compressed TAR file
alias untargz='tar -xzvf'  # Extract gzipped TAR files

# Disk Space and Usage
alias duh='du -h --max-depth=1'  # Directory sizes in the current location in human-readable format
alias dfh='df -hT'  # Disk space usage with file system type

# SSH
alias sshk='ssh-keygen -t rsa -b 4096'  # Generate a new RSA key for SSH

# Miscellaneous
alias pathlist='echo $PATH | tr ":" "\n"'  # Display PATH directories line by line
alias histc='history -c'  # Clear command history
alias histn='history | nl'  # Numbered command history

# `exa` is a modern replacement for `ls`
alias l='exa'
alias ll='exa -lh'
alias la='exa -la'
alias llt='exa -lT'  # tree view

# `bat` is like `cat` but with syntax highlighting and git integration
alias c='bat'

# `fd` is a simpler and faster alternative to `find`
alias f='fd --type f'  # Find files
alias d='fd --type d'  # Find directories

# `ripgrep (rg)` is a faster `grep` replacement
alias rg='rg --colors "match:fg:yellow" --colors "line:bg:blue" --colors "path:fg:green"'

# `htop` is an interactive process viewer, an alternative to `top`
alias top='htop'

# `ncdu` is a disk usage analyzer with a ncurses interface
alias du='ncdu'

# `zoxide` is a smarter `cd` command. It learns your habits to help navigate faster
alias j='zoxide query'
alias ji='zoxide interactive'  # interactive mode

# `fzf` is a general-purpose command-line fuzzy finder
alias histf='history | fzf'  # search through command history with fzf
alias cdf='cd $(find /path/to/search/root -type d | fzf)'  # Change directory with fzf

# `glances` is an alternative to `top` and `htop`
alias glance='glances'

# `delta` is a viewer for git and diff output
alias gdiff='git diff | delta'
alias gshow='git show | delta'

# `jq` is a lightweight and flexible command-line JSON processor
alias json='jq .'

# `httpie (http)` is a user-friendly curl replacement
alias get='http GET'
alias post='http POST'

# `tldr` provides simplified and community-driven man pages
alias man='tldr'

# `z` lets you navigate through your directory history
alias zs='z -l'  # List frequent directories

# `dd` for disk cloning and data rescue
alias diskcopy='dd bs=64k'  # Adjust block size (bs) as needed

# `lsof` helps identify what processes have files open
alias portuse='lsof -i -n -P'  # Find which process is using a specific port

# `strace` traces system calls and signals of a specific process
alias traceproc='strace -C -f -p'  # Attach to process and trace its calls

# `nc` (Netcat) is a versatile networking tool
alias portlisten='nc -l -p'  # Listen on a specific port

# `mtr` combines the functionality of the traceroute and ping programs
alias tracepath='mtr --report --report-cycles=10'  # Run trace for 10 cycles and report

# `dig` delves into DNS details
alias dnscheck='dig +short'  # Get the IP of a domain

# `hdparm` gets/sets SATA/IDE device parameters
alias diskperf='sudo hdparm -tT'  # Test drive read performance

# `chroot` changes the root directory (useful for system rescues)
alias chrootdir='sudo chroot'

# `iftop` displays bandwidth usage on an interface by host
alias nettop='sudo iftop'

# `john` the Ripper is a password cracker
alias crackpass='john --wordlist=/path/to/wordlist'  # Specify path to wordlist

# `testdisk` is a powerful free data recovery software
alias recoverpart='sudo testdisk'

# `pv` allows a user to view the progress of data through a pipeline
alias pipeview='pv'

# `tcpdump` is a packet analyzer
alias dumptraffic='sudo tcpdump -i any -w /path/to/output.pcap'  # Capture packets on any interface

# `nmap` scans open ports on a network
alias scanports='nmap -F'  # Fast mode

# `gpg` for encryption and signing
alias encryptfile='gpg -c'  # Encrypt a file
alias decryptfile='gpg -d'  # Decrypt a file

# `rsync` for efficient file transfers & synchronizing
alias syncdir='rsync -avh --progress'  # Verbose, human-readable, with progress

# `iotop` checks I/O usage by processes
alias iomon='sudo iotop -oP'  # Display only processes doing I/O

# `sar` collects and reports system activity
alias cpuload='sar -u 1 5'  # CPU load, every second, for 5 seconds

# `watch` runs a command repeatedly, showing results and/or changes
alias watchcmd='watch -n 10'  # Run every 10 seconds

# `jq` processes JSON in the command line.
alias jsonf='jq .'

# `yq` is like `jq`, but for YAML.
alias yamlf='yq .'

# `xmlstarlet` is a command-line XML toolkit
alias xmlq='xmlstarlet sel -t -c'

# `parallel` executes jobs in parallel
alias par='parallel'

# `paste` merges lines of files
alias merge='paste'

# `seq` generates sequences of numbers
alias sequence='seq'

# `rlwrap` provides readline features like history and completion to commands that lack them
alias wrapread='rlwrap'

# Custom function to check if a program is installed
is_installed() {
  command -v "$1" >/dev/null 2>&1
}

# Custom function to safely create a backup of a file
backup_file() {
  [ -f "$1" ] && cp "$1" "$1.$(date +%Y%m%d%H%M%S).bak"
}

# Custom function to check and wait for an open port
wait_for_port() {
  local port=$1
  local retries=${2:-5}
  local wait_time=${3:-5}

  while ! nc -z 127.0.0.1 "$port" && [ $retries -gt 0 ]; do
    echo "Waiting for port $port to be open..."
    sleep "$wait_time"
    retries=$((retries - 1))
  done
}

# Custom function to get the size of a directory or file
get_size() {
  du -sh "$1" 2>/dev/null | cut -f1
}

# Custom function to count lines in a file
count_lines() {
  wc -l "$1" | awk '{print $1}'
}

# Custom function to find and replace text in files recursively
find_and_replace() {
  local search="$1"
  local replace="$2"
  local path="${3:-.}"
  local extension="${4:-*}"

  grep -rl "$search" "$path" --include="*.$extension" | xargs sed -i "s/$search/$replace/g"
}

# `dos2unix` and `unix2dos` convert between DOS and UNIX text file formats
alias to_unix='dos2unix'
alias to_dos='unix2dos'

# `timeout` runs a command with a time limit
alias runlim='timeout'

# Custom function to determine the operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "Mac";;
        CYGWIN*)    echo "Cygwin";;
        MINGW*)     echo "MinGW";;
        *)          echo "Unknown"
    esac
}

# Custom function to get the public IP
get_public_ip() {
  curl -s http://ipinfo.io/ip
}

# Custom function to quickly create directories and navigate into them
mkdir_cd() {
  mkdir -p "$1" && cd "$1"
}

# Custom function to create a new file and open it in an editor (e.g., vim)
vim_new() {
  touch "$1" && vim "$1"
}

# Custom function to display the most memory-consuming processes
top_mem() {
  ps aux --sort=-%mem | head -n ${1:-10}
}

# Custom function to display the most CPU-consuming processes
top_cpu() {
  ps aux --sort=-%cpu | head -n ${1:-10}
}

# Custom function to quickly set permissions for web projects
set_web_permissions() {
    local directory="$1"
    sudo chown -R www-data:www-data "$directory"
    find "$directory" -type d -exec chmod 755 {} \;
    find "$directory" -type f -exec chmod 644 {} \;
}

# Custom function to check SSL certificate details
check_ssl() {
    echo | openssl s_client -showcerts -servername "$1" -connect "$1":443 2>/dev/null | openssl x509 -inform pem -noout -text
}

# Custom function to archive and compress a directory
tar_zip() {
    tar czf "$1.tar.gz" "$1"
}

# Custom function to extract various archive types
extract() {
    case $1 in
        *.tar.bz2)  tar xjf "$1"     ;;
        *.tar.gz)   tar xzf "$1"     ;;
        *.bz2)      bunzip2 "$1"     ;;
        *.rar)      rar x "$1"       ;;
        *.gz)       gunzip "$1"      ;;
        *.tar)      tar xf "$1"      ;;
        *.tbz2)     tar xjf "$1"     ;;
        *.tgz)      tar xzf "$1"     ;;
        *.zip)      unzip "$1"       ;;
        *.Z)        uncompress "$1"  ;;
        *.7z)       7z x "$1"        ;;
        *)          echo "'$1' cannot be extracted via this function" ;;
    esac
}

# Encrypt a file with a passphrase
alias encrypt='gpg --cipher-algo AES256 --symmetric'

# Decrypt a gpg-encrypted file
alias decrypt='gpg --decrypt'

# Generate a new key pair
alias genkey='gpg --gen-key'

# List keys in your public key ring
alias listkeys='gpg --list-keys'

# List keys in your secret key ring
alias listsecretkeys='gpg --list-secret-keys'

# Export a public key to file
alias exportkey='gpg --armor --export -o pubkey.asc'

# Import a public key from a file
alias importkey='gpg --import'

# Encrypt a file for a specific recipient using their public key
alias encryptfor='gpg --encrypt --trust-model always'

# Encrypt and sign a file for a specific recipient
alias encryptsignfor='gpg --encrypt --sign --trust-model always'

# Sign a file
alias sign='gpg --sign'

# Verify the signature of a file
alias verify='gpg --verify'

# Remove a key from the public key ring
alias delkey='gpg --delete-key'

# Remove a key from the secret key ring
alias delsecretkey='gpg --delete-secret-key'

# Encrypt a folder using tar and gpg
encryptdir() {
  tar czf - "$1" | gpg --cipher-algo AES256 --symmetric -o "$1.tar.gz.gpg"
}

# Decrypt a gpg encrypted tarball and then extract it
decryptdir() {
  gpg --decrypt "$1" | tar xzf -
}

# `awk` is a powerful tool for text processing
alias csv2tsv='awk -F"," -v OFS="\t"'
alias tsv2csv='awk -F"\t" -v OFS=","'

# `cut` removes sections from each line of files
alias cutf='cut -f'  # Useful for tab-separated values
alias cutc='cut -c'  # Useful for fixed-width data

# `sed` is a stream editor for filtering and transforming text
alias delines='sed "/^$/d"'       # Delete empty lines
alias no_comments='sed "/^#/d"'   # Remove commented lines starting with #
alias trim='sed "s/^[ \t]*//;s/[ \t]*$//"'  # Trim whitespace from beginning & end

# `sort` sorts lines in text files
alias sortn='sort -n'    # Sort numerically
alias sortk='sort -k'    # Sort by a specific column

# `uniq` removes or identifies duplicate lines
alias uniqc='uniq -c'    # Show count of occurrences
alias uniqd='uniq -d'    # Only show duplicate lines

# `grep` searches for specific patterns within files
alias igrep='grep -i'    # Case-insensitive search
alias vgrep='grep -v'    # Invert match

# `wc` counts words, lines, characters, etc.
alias wcl='wc -l'   # Count lines
alias wcc='wc -c'   # Count bytes
alias wcw='wc -w'   # Count words

# `tr` translates characters
alias lowercase='tr "A-Z" "a-z"'
alias uppercase='tr "a-z" "A-Z"'

# `comm` compares two sorted files line by line
alias comm_unique1='comm -23'  # Lines unique to file1
alias comm_unique2='comm -13'  # Lines unique to file2
alias comm_common='comm -12'   # Lines common to both

# Custom function to replace delimiters
# Usage: replacedelims <input_delim> <output_delim> <file>
replacedelims() {
  local input_delim="$1"
  local output_delim="$2"
  awk -F"${input_delim}" -v OFS="${output_delim}" '{$1=$1; print}' "$3"
}

# `join` joins two files based on common fields
# By default, uses the first field as the join key
alias joinfiles='join'

# `paste` merges lines of files
alias merge_horizontally='paste'
alias merge_vertically='cat'

# `column` command is a simple utility for formatting its input into multiple columns
alias tabulate='column -t'

# `q` allows executing SQL-like queries on CSV/TSV files
# General pattern: q "SQL QUERY" -d DELIMITER

# Select first 10 lines (akin to SQL's LIMIT)
alias qlimit10="q 'SELECT * from - LIMIT 10' -d ','"

# Count the number of lines (akin to SQL's COUNT)
alias qcount="q 'SELECT COUNT(*) from -' -d ','"

# Custom function to select specific columns by name
# Usage: qselect "col1,col2" <file>
qselect() {
  local columns="$1"
  q "SELECT ${columns} from -" -d ',' "$2"
}

# Custom function to filter rows based on a condition
# Usage: qwhere "col1='value'" <file>
qwhere() {
  local condition="$1"
  q "SELECT * from - WHERE ${condition}" -d ',' "$2"
}

# Custom function to perform a join on two files based on a column
# Usage: qjoin "col_name" file1.csv file2.csv
qjoin() {
  local join_column="$1"
  local file1="$2"
  local file2="$3"
  q "SELECT * from ${file1} a JOIN ${file2} b ON a.${join_column} = b.${join_column}" -d ','
}

# Custom function to perform group by operations
# Usage: qgroupby "col_name, count(*)" "col_name" <file>
qgroupby() {
  local select_cols="$1"
  local groupby_col="$2"
  q "SELECT ${select_cols} from - GROUP BY ${groupby_col}" -d ',' "$3"
}

# Custom function to sort data based on a column
# Usage: qorderby "col_name DESC" <file>
qorderby() {
  local order_cols="$1"
  q "SELECT * from - ORDER BY ${order_cols}" -d ',' "$2"
}

# SELECT: Using `cut` to emulate SQL's SELECT for specific columns by their numbers.
# For a TSV file, selecting columns 2 and 5:
# Usage: select_cols "2,5" <file>
select_cols() {
    cut -f"$1" "$2"
}

# WHERE: Using `awk` to filter rows based on conditions, emulating SQL's WHERE clause.
# Usage: where_col_equals "2" "value" <file>
where_col_equals() {
    awk -F'\t' -v col="$1" -v val="$2" '$col == val' "$3"
}

# JOIN: Emulate SQL's INNER JOIN for two TSV files based on a common column.
# Usage: join_on_col "1" file1.tsv file2.tsv
join_on_col() {
    join -1 "$1" -2 "$1" -t $'\t' "$2" "$3"
}

# GROUP BY: Using `awk` and `sort` to group by a column and count occurrences.
# For a TSV file, grouping by column 1 and counting:
# Usage: group_by_col "1" <file>
group_by_col() {
    awk -F'\t' -v col="$1" '{print $col}' "$2" | sort | uniq -c | awk '{print $2"\t"$1}'
}

# ORDER BY: Using `sort` to emulate SQL's ORDER BY for sorting by a specific column.
# Usage: order_by_col "2" <file>
order_by_col() {
    sort -k"$1" "$2"
}

# DISTINCT: Using `sort` and `uniq` to get distinct rows, emulating SQL's DISTINCT.
# For a TSV file:
# Usage: distinct_rows <file>
distinct_rows() {
    sort "$1" | uniq
}

# LIMIT: Using `head` to limit the number of results, emulating SQL's LIMIT.
# Usage: limit_rows "10" <file>
limit_rows() {
    head -n "$1" "$2"
}

# AGGREGATE (SUM): Using `awk` to sum values in a specific column.
# Usage: sum_col "3" <file>
sum_col() {
    awk -F'\t' -v col="$1" '{sum += $col} END {print sum}' "$2"
}

# AGGREGATE (AVG): Using `awk` to average values in a specific column.
# Usage: avg_col "3" <file>
avg_col() {
    awk -F'\t' -v col="$1" '{sum += $col; count++} END {print sum/count}' "$2"
}

# FILTER: Using `grep` to filter rows containing a specific pattern.
# Usage: filter_rows "pattern" <file>
filter_rows() {
    grep "$1" "$2"
}

# Applies a function to each line of input
# Usage: map "command" < file
# map() {
#    while read -r line; do
#        echo "$line" | $1
#    done
#}

# Filters lines based on a predicate function's exit status
# Usage: filter "command" < file
#filter() {
#    while read -r line; do
#        echo "$line" | $1 >/dev/null && echo "$line"
#    done
#}

# Initialize a new repository in the local directory "backup"
alias restic_init='restic init --repo ~/backup'

# Back up a specific directory
# Usage: restic_backup_dir "/path/to/directory"
restic_backup_dir() {
    restic -r ~/backup backup "$1"
}

# List all snapshots
alias restic_list_snapshots='restic -r ~/backup snapshots'

# Restore latest snapshot to a specific directory
# Usage: restic_restore_latest "/path/to/restore"
restic_restore_latest() {
    restic -r ~/backup restore latest --target "$1"
}

# Delete a specific snapshot
# Usage: restic_delete_snapshot "snapshot_id"
restic_delete_snapshot() {
    restic -r ~/backup forget "$1"
}

# Check the repository for errors
alias restic_check='restic -r ~/backup check'

# Prune old backups (this is useful to reclaim space after deleting snapshots)
alias restic_prune='restic -r ~/backup prune'

# List all files in the latest snapshot
alias restic_ls_latest='restic -r ~/backup ls latest'

# Mount all snapshots to a specific directory
# Usage: restic_mount "/path/to/mountpoint"
restic_mount() {
    restic -r ~/backup mount "$1"
}

# Unlock the repository in case a lock is stuck
alias restic_unlock='restic -r ~/backup unlock'

# Display statistics about the repository
alias restic_stats='restic -r ~/backup stats'

# Execute a clean build
alias gradle_clean_build='./gradlew clean build'

# Run tests
alias gradle_test='./gradlew test'

# Generate the project's Javadoc
alias gradle_javadoc='./gradlew javadoc'

# Run the application (assumes you're using the application plugin)
alias gradle_run='./gradlew run'

# Publish the project (assuming you're using the maven-publish plugin or similar)
alias gradle_publish='./gradlew publish'

# List all available tasks
alias gradle_tasks='./gradlew tasks'

# Run a specific task; provide the task name as an argument
# Usage: gradle_task assemble
gradle_task() {
    ./gradlew "$1"
}

# Check for dependency updates (assuming you're using the "ben-manes/gradle-versions-plugin")
alias gradle_dependency_updates='./gradlew dependencyUpdates'

# Run the bootRun task (if you're using Spring Boot)
alias gradle_boot_run='./gradlew bootRun'

# Generate a project report (assuming you're using the "project-report" plugin)
alias gradle_project_report='./gradlew projectReport'

# Refresh the dependencies (useful when snapshots have been updated)
alias gradle_refresh_dependencies='./gradlew --refresh-dependencies'

# Run with continuous build - watches the file system and recompiles automatically
# when changes are detected (useful for development)
alias gradle_continuous_build='./gradlew --continuous'

# Execute a clean build skipping tests
alias gradle_clean_build_skip_tests='./gradlew clean build -x test'

# Display the Gradle, Groovy, Ant, JVM, and OS versions
alias gradle_version='./gradlew --version'

# Execute the build with the "info" log level for more detailed output
alias gradle_info='./gradlew build --info'

# Execute the build with the "debug" log level for even more detailed output
alias gradle_debug='./gradlew build --debug'

# Generate a build scan (requires you've added the 'com.gradle.build-scan' plugin)
alias gradle_scan='./gradlew build --scan'

# Show performance statistics for the build
alias gradle_profile='./gradlew build --profile'

# Show reasons for project dependencies (why a dependency is used)
# Usage: gradle_dependency_insight "dependency-name"
gradle_dependency_insight() {
    ./gradlew dependencyInsight --dependency "$1"
}

# Lists the dependencies for all the subprojects
alias gradle_dependencies='./gradlew dependencies'

# Displays a tree of the tasks that would be executed for the task name you specify
# Usage: gradle_task_tree "task-name"
gradle_task_tree() {
    ./gradlew "$1" --dry-run
}

# Lists all projects in the current build
alias gradle_projects='./gradlew projects'

# Check for circular dependencies in your project
alias gradle_check_circular='./gradlew checkCircularDependencies'

# Find out which task is out-of-date and will be executed
alias gradle_out_of_date='./gradlew build --dry-run'

# Run a build with a clean environment (useful to rule out local environment issues)
alias gradle_refresh='./gradlew clean --refresh-dependencies'

# 'install' equivalent
alias nix_install='nix-env -iA nixpkgs.'

# 'remove/uninstall' equivalent
alias nix_uninstall='nix-env -e'

# 'search' equivalent
alias nix_search='nix-env -qaP'

# 'update' or 'upgrade' equivalent
# For Nix, updating the package list and upgrading installed packages are two separate actions
alias nix_update_list='nix-channel --update'
alias nix_upgrade_all='nix-env -u'

# 'list' installed packages equivalent
alias nix_list_installed='nix-env -q'

# 'info' equivalent for detailed package information
# Usage: nix_info "package-name"
nix_info() {
    nix-env -qaP "$1" --description --out-path
}

# 'clean' equivalent to remove old generations and free up space
alias nix_clean='nix-collect-garbage -d'

# 'add repository' equivalent (though Nix channels work a bit differently)
# Usage: nix_add_channel "channel-name" "channel-URL"
nix_add_channel() {
    nix-channel --add "$2" "$1"
}

# 'remove repository' equivalent
# Usage: nix_remove_channel "channel-name"
nix_remove_channel() {
    nix-channel --remove "$1"
}

# 'list repositories' equivalent
alias nix_list_channels='nix-channel --list'

# Install a specific version of a package
# Usage: nix_install_version "package-name" "version"
nix_install_version() {
    nix-env -iA "nixpkgs.$1-$2"
}

# Rollback to the previous configuration
alias nix_rollback='nix-env --rollback'

# List available rollbacks
alias nix_list_rollbacks='nix-env --list-generations'

# Switch to a specific rollback
# Usage: nix_switch_generation "generation-number"
nix_switch_generation() {
    nix-env --switch-generation "$1"
}

# Create an isolated shell environment with specific packages
# Usage: nix_shell_with "pkg1 pkg2 ..."
nix_shell_with() {
    nix-shell -p $1
}

# Build a package from a given Nix expression without installing
# Usage: nix_build_expression "/path/to/expression.nix"
nix_build_expression() {
    nix-build "$1"
}

# Use a package temporarily without affecting the user environment
# Usage: nix_run_temp "package-name" "command"
# Example: nix_run_temp "python39" "python --version"
nix_run_temp() {
    nix run nixpkgs.$1 -c $2
}

# Show the derivation for a package
# Usage: nix_show_derivation "package-name"
nix_show_derivation() {
    nix show-derivation $(nix-instantiate '<nixpkgs>' -A $1)
}

# Build a Docker image from a Nix expression
# Usage: nix_build_docker "/path/to/expression.nix"
nix_build_docker() {
    nix-build "$1" -o result-docker && docker load < result-docker
}

# Show the difference between the current generation and the previous one
alias nix_diff_generations='nix-env --compare-generations'

# Initialize a new Kotlin project with Gradle
# Usage: kotlin_init_project "project-name"
kotlin_init_project() {
    mkdir "$1" && cd "$1"
    gradle init --dsl kotlin --type kotlin-application
}

# Create a new Kotlin library project with Gradle
# Usage: kotlin_init_library "library-name"
kotlin_init_library() {
    mkdir "$1" && cd "$1"
    gradle init --dsl kotlin --type kotlin-library
}

# Build the Kotlin project
# This assumes you're in the project directory
alias kotlin_build='./gradlew build'

# Run the Kotlin application
# This assumes you're in the project directory and it's an application (not a library)
alias kotlin_run='./gradlew run'

# Run tests for the Kotlin project
# This assumes you're in the project directory
alias kotlin_test='./gradlew test'

# Clean the Kotlin project (remove build artifacts)
# This assumes you're in the project directory
alias kotlin_clean='./gradlew clean'

# Generate a JAR for the Kotlin project
# This assumes you're in the project directory
alias kotlin_jar='./gradlew jar'

# If you want to use Ktor (Kotlin web framework) for creating web projects, you can use:
# Usage: kotlin_init_ktor "project-name"
kotlin_init_ktor() {
    mkdir "$1" && cd "$1"
    # Here you might utilize a specific Ktor project generator or a template
}

# If you're into mobile development with Kotlin for Android:
# Usage: kotlin_init_android "app-name"
kotlin_init_android() {
    # Use the Android Studio's command-line tools or your preferred method to initialize an Android project with Kotlin.
}

# Install a package
alias npmi="npm install"

# Install a package globally
alias npmig="npm install -g"

# Uninstall a package
alias npmun="npm uninstall"

# Start the script from package.json
alias npms="npm start"

# Run build script from package.json
alias npmb="npm run build"

# List globally installed packages
alias npmgl="npm list -g --depth=0"

# Update npm packages
alias npmup="npm update"

# Init a new npm project
alias npminit="npm init"

# Run tests
alias npmt="npm test"

# Display the current version of installed npm package
alias npmv="npm -v"

# Install a package
alias ppi="pnpm install"

# Install a package globally
alias ppig="pnpm install -g"

# Uninstall a package
alias ppun="pnpm uninstall"

# Start the script from package.json
alias pps="pnpm start"

# Run build script from package.json
alias ppb="pnpm run build"

# List globally installed packages
alias ppgl="pnpm list -g --depth=0"

# Update pnpm packages
alias ppup="pnpm update"

# Init a new pnpm project
alias ppinit="pnpm init"

# Run tests
alias ppt="pnpm test"

# Display the current version of installed pnpm package
alias ppv="pnpm -v"

# Install a specific version of Node.js
# Usage: nvi 14 (for Node.js 14.x)
nvi() {
    nvm install $1
}

# Use a specific version of Node.js
# Usage: nvu 14 (for Node.js 14.x)
nvu() {
    nvm use $1
}

# List installed Node.js versions
alias nvl="nvm ls"

# List all available Node.js versions to install
alias nvlr="nvm ls-remote"

# Set a default Node.js version
# Usage: nvd 14 (for Node.js 14.x)
nvd() {
    nvm alias default $1
}

# Update Node.js version with nvm
alias nvmup="nvm install node && nvm use node && nvm alias default node"

# Update npm to the latest version
alias npmup="npm install -g npm"

# Update pyenv and install latest Python version
alias pyenvup='pyenv update && pyenv install $(pyenv install -l | grep -v "[a-z]" | tail -1) && pyenv global $(pyenv install -l | grep -v "[a-z]" | tail -1)'

# Upgrade pip to the latest version
alias pipup="pip install --upgrade pip"

# Update rbenv and ruby-build, then install the latest Ruby version
alias rbenvup='rbenv update && rbenv install $(rbenv install -l | tail -1) && rbenv global $(rbenv install -l | tail -1)'

# Update all installed gems
alias gemup="gem update"

# Update SDKMAN!
alias sdkup="sdk update"

# Update Java using SDKMAN!
alias javasdkup="sdk upgrade java"

# Update Kotlin using SDKMAN!
alias kotlinsdkup="sdk upgrade kotlin"

# Clean-up outdated and unused packages
alias npmclean="npm prune && npm outdated"

# List outdated Python packages
alias pipout="pip list --outdated"

# Clean-up old versions of installed gems
alias gemclean="gem cleanup"

# List all available SDKs in SDKMAN!
alias sdkls="sdk list"
