#!/bin/bash
# bash_search https://github.com/Magnushhoie/bash_search
# Scripts primarily sourced from: https://github.com/junegunn/fzf/wiki/examples

# Check shell for zsh compatibility
zsh_shell=$(ps -p $$ | grep zsh)
if [[ $zsh_shell ]]; then
    export fuzzy_commands_dir=$( dirname ${0:a} )
else
    export fuzzy_commands_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi
export string2arg_file="$fuzzy_commands_dir/string2arg.sh"

# Max depth to search for in f_files and f_size
export F_MAXDEPTH=4

# Nice coloring on man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"

# ripgrep defaults. Change this to allow deeper searches
export rg="rg --max-count 1000000 --max-depth 10 --max-filesize 1M"

# FZF defaults
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_DEFAULT_COMMAND="fd --type file --color=always"
export FZF_DEFAULT_OPTS="--reverse --inline-info --ansi"
export FZF_COMPLETION_TRIGGER=']]'

# Default command to use when input is tty
export FZF_DEFAULT_COMMAND="fd --type f --color=always"
# Using bat as previewer
export FZF_CTRL_T_OPTS="--preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
_fzf_compgen_path () {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir () {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}


function f_help ()    # Show list of commands
{
echo -e $(realpath $fuzzy_commands_dir/fuzzy_commands.sh:)
echo -e
echo -e "FZF terminal shortcuts:"
echo -e "Control + R search bash history"
echo -e "Control + T search files"
echo -e "Escape + C jump to folder\n"
grep --color=always "^function " $fuzzy_commands_dir/fuzzy_commands.sh
}

# fo [FUZZY PATTERN] - Open the selected file with the default editor
# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
function f_open()     # Open the selected file. Hotkeys CTRL+O (open) or CTRL+E ($EDITOR)
{
  IFS=$'\n' out=("$(fzf-tmux -e --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

function f_search ()  # Search all lines in all files, recursively
{
search_terms=${@:-"."}
local vfile
export vfile=$(rg --color=always -m 100000 --max-depth 10 -i -n -g "!*.html" "$search_terms" | fzf -e --preview="source $string2arg_file; string2arg {}")
if [[ "$vfile" =~ [a-zA-Z0-9] ]];
#if [[ -z "$vfile" ]];
   then echo $vfile
   vim +$(cut -d":" -f2 <<< $vfile) $(cut -d":" -f1 <<< $vfile)
fi
}

function f_file ()    # Find in file, preview contents
{
echo "Searching in files $F_MAXDEPTH levels deep (set with F_MAXDEPTH)"
search_terms=${@:-"\s"}
    if [ ! "$#" -gt 0 ]; then echo "Usage: f_file <keywords>"; fi
    local file
    file=$(rga --max-count=1 --max-depth $F_MAXDEPTH --max-filesize 1M --ignore-case --files-with-matches --no-messages "$1.*$2.*$3.$4.$5.$6" |
     fzf-tmux -e +m --preview="rga --ignore-case --pretty --context 10 $1.*$2.*$3.$4.$5.$6 {}") && vim +":set hlsearch" "+/$1.*$2.*$3.*$4.*$5" "$file" && echo $(realpath $file)
     echo $file
}

function f_folder ()  # Search folder names and cd
{
  pwd
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf -e +m --preview 'ls {}') && cd "$dir" && pwd
}

function f_view ()    # View files in folder, preview content and open in vim
{
    local file=$(
      ls -p |  grep -v / | fzf -e --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :1000 {}'
      )
    # If file, open in vim. Otherwise change directory, run again
    if [[ -f $file ]]; then
        realpath "$file"
        vim "$file"
    else
        echo "No files in folder $PWD"
    fi
}

function f_size ()    # Show cumulative file size for each file extension in folder, n-levels (default 4) deep
{
# Bash find total file size of each type of extension in folder
echo "Showing file-sizes "${1:-$F_MAXDEPTH}" levels deep (default 4)"
find . -maxdepth "${1:-$F_MAXDEPTH}" -name '?*.*' -type f -print0 2> /dev/null |
  perl -0ne '
    if (@s = stat$_){
      ($ext = $_) =~ s/.*\.//s;
      $s{$ext} += $s[12];
      $n{$ext}++;
    }
    END {
      for (sort{$s{$a} <=> $s{$b}} keys %s) {
        printf "%15d %4d %s\n",  $s{$_}<<9, $n{$_}, $_;
      }
    }' | numfmt --to=iec-i --suffix=B | tac |
    fzf -e --preview="source $string2arg_file; string2arg_filesize {} "
}

function f_hist ()    # Search BASH History: Fuzzy search bash history
{
  echo -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf -e +s --tac | awk '{print $FN}')
}

function f_cd ()      # Interactive cd with fzf
{
  pwd
    if [[ "$#" != 0 ]]; then
        builtin cd "$@";
        return
    fi
    while true; do
        local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
        local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                ls -p -FG "${__cd_path}";
        ')"
        [[ ${#dir} != 0 ]] || return 0
        builtin cd "$dir" &> /dev/null
        pwd
    done
}

alias gll='fzf_git_log'
git config --global alias.ll 'log --graph --format="%C(yellow)%h%C(red)%d%C(reset) - %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)"'
function f_git_log () # Interactive git log (AWESOME)
{
    local selections=$(
      git ll --color=always "$@" |
        fzf --ansi --no-sort --height 100% \
            --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                       xargs -I@ sh -c 'git show --color=always @'"
      )
    if [[ -n $selections ]]; then
        local commits=$(echo "$selections" | cut -d' ' -f2 | tr '\n' ' ')
        git show $commits
    fi
}

function f_git_branch() # checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
{
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

function f_kill ()    # Interactively kill process
{
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

function f_man ()     # Search bash manual
{
    man -k . | fzf -e --prompt='Man> ' --preview "echo {} | awk '{print $1}' | cut -f1 -d\( | xargs man" |
    awk '{print $1}' | cut -f1 -d\( | xargs man
}

function f_pdf ()     # Search all PDFs in folder, recursively
{
    local open
    open=open   # on OSX, "open" opens a pdf in preview
    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | gtr " " "|");
            echo -e {1}"\n"{2} | ggrep -E "^|$v" -i --color=always;
        ' \
    | gcut -z -f 1 -d $'\t' | gtr -d '\n' | gxargs -r --null $open > /dev/null 2> /dev/null
}

function f_vim()      # Quick access files with fasd
{
  local file
  file="$(fasd -Rfl "$1" | fzf -e --no-multi --select-1 --exit-0 \
      --preview 'bat --color=always --line-range :1000 {}')" && vi "${file}" || return 1
}

function f_chrome()   # Search chrome bookmarks
{
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf -e --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}