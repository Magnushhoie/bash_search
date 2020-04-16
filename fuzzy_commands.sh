#!/bin/bash

#https://github.com/junegunn/fzf/wiki/examples

#Awesome shortcuts:
# Control + r search bash history
# Control + T search files
# Escape + C jump to folder
EDITOR=vim

fuzzy_commands="${BASH_SOURCE[0]}"

function f_help () # Show list of commands
{
echo $(realpath $fuzzy_commands)
grep --color=always "^function " $fuzzy_commands
}

function f_helpv() # Edit (this) fuzzy_commands.sh file
{
vim $fuzzy_commands
}

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
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

function fsearch() # Interactive Search file contents in folder
{
search_terms=${@:-"."}
local vfile
export vfile=$(rg -m 100000 --max-depth 10 -n -g "!*.html" "$search_terms" | fzf -e --preview="source $string2arg_file; string2arg {}")
if [[ $vfile ]]; 
   then vim +$(cut -d":" -f2 <<< $vfile) $(cut -d":" -f1 <<< $vfile)
fi  
}

function fif() # Find in Folder: Search file contents, only show matching file once
{
search_terms=${@:-" "}
    if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
    local file
    file=$(rga --max-count=1 --max-depth 10 --ignore-case --files-with-matches --no-messages "$search_terms" | fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 $@ {}") && vim +":set hlsearch" +/$1.*$2.*$3.*$4.*$5 "$file"
}

function fcd() # Interactive change-directory with fzf
{
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
    done
}

function fh() # Find BASH History: Fuzzy search bash history
{
  echo -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | awk '{print $FN}')
}

function f_filenames() # Fuzzy search filenames, preview content and open in vim
{
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
      )
    if [[ -n $file ]]; then
        $EDITOR "$file"
    fi
}

function f_folders() # Fuzzy search all subdirectories and cd
{
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf -e +m --preview 'ls {}') && cd "$dir"
}

function f_git_log() # Interactive look at git log
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

alias gll='fzf_git_log'
git config --global alias.ll 'log --graph --format="%C(yellow)%h%C(red)%d%C(reset) - %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)"'

function f_kill() # kill processes - list only the ones you can kill.
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

function f_browser_bookmarks() # Fuzzy search all browser bookmarks. Setup with pip3 install buku; buku --suggest ai
{
    chrome $(buku -p -f 40 | awk -F '\t' '{print $2"\t"$1}' | fzf -e | awk -F '\t' '{print $NF}' | sed 's/https:\/\///')
}

function f_browser_history() # Safari and Chrome browser history search
{
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  safari_temp=$(mktemp)
  chrome_temp=$(mktemp)

  #Safari
  cp -f ~/Library/Safari/History.db /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(id, 1, $cols), url
     from history_items order by visit_count_score desc" > $safari_temp

  #Chrome
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
      from urls order by last_visit_time desc" > $chrome_temp

  #Combine
  cat $chrome_temp $safari_temp |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf -e --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

function f_browser_history_firefox() # Firefox history search (hardcoded path - change with f_helpv)
{

local cols sep google_history open
cols=$(( COLUMNS / 3 ))
sep='{::}'

history="$HOME/Library/Application Support/Firefox/Profiles/xcrc0wh4.default/places.sqlite"
open=xdg-open

cp -f "$history" /tmp/h
sqlite3 -separator $sep /tmp/h \
  "select substr(id, 1, $cols), url
   from history_items order by visit_count_score desc" |
awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

function f_man() # Bash manuals search
{
    man -k . | fzf -e --prompt='Man> ' --preview "echo {} | awk '{print $1}' | cut -f1 -d\( | xargs man" |
    awk '{print $1}' | cut -f1 -d\( | xargs man
}

function f_pdf () # Search all PDFs in folder, recursively
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

function f_v() #open last used vim files in ~/.viminfo
{
  local files
  IFS=$'\n'
  files=$(grep '^>' ~/.viminfo | cut -c3- |
          while read line; do
            [ -f "${line/\~/$HOME}" ] && echo $line | sed "s#~#$HOME#"
          done |
    fzf -e --no-multi --select-1 --exit-0 \
        --preview 'bat --color=always --line-range :100 {}'
    )
  if [[ -n $files ]]; then
      vim ${files//\~/$HOME}
  fi
}
