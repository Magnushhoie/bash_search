#!/bin/bash

#https://github.com/junegunn/fzf/wiki/examples

#Awesome shortcuts:
# Control + r search bash history
# Control + T search files
# Escape + C jump to folder

EDITOR=vim
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
alias b='buku --suggest'

# alternative using ripgrep-all (rga) combined with fzf-tmux preview
# implementation below makes use of "open" on macOS, which can be replaced by other commands if needed.
# allows to search in PDFs, E-Books, Office documents, zip, tar.gz, etc. (see https://github.com/phiresky/ripgrep-all)
# find-in-file - usage: fif <searchTerm> or fif "string with spaces" or fif "regex"
fif() {
    if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
    local file
    file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$@" | fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 '"$@"' {}")" && vim +":set hlsearch" +/$1.*$2.*$3.*$4.*$5 "$file"
}

fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
}

fh() {
  echo -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | awk '{print $FN}')
}

fzf_find_edit() {
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
      )
    if [[ -n $file ]]; then
        $EDITOR "$file"
    fi
}
alias ffe='fzf_find_edit'

fzf_grep_edit(){
    if [[ $# == 0 ]]; then
        echo 'Error: search term was not provided.'
        return
    fi
    local match=$(
      rg --ignore-case --color=never --line-number "$1" |
        fzf --no-multi --delimiter : \
            --preview "bat --color=always --line-range {2}: {1}"
      )
    local file=$(echo "$match" | cut -d':' -f1)
    if [[ -n $file ]]; then
        $EDITOR "$file" +$(echo "$match" | cut -d':' -f2)
    fi
}

alias fge='fzf_grep_edit'


fzf_git_log() {
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


# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}


# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
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


# Search browser histories and bookmarks
fb() {
    chrome $(buku -p -f 40 | awk -F '\t' '{print $2"\t"$1}' | fzf -e | awk -F '\t' '{print $NF}' | sed 's/https:\/\///')
}

# c - browse chrome history
history_safari() {
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  cp -f ~/Library/Safari/History.db /tmp/h

  sqlite3 -separator $sep /tmp/h \
    "select substr(id, 1, $cols), url
     from history_items order by visit_count_score desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}'  |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

fhist() {
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

history_chrome() {
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
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

history_firefox() {

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

fman() {
    man -k . | fzf -e --prompt='Man> ' | awk '{print $1}' | cut -f1 -d\( | xargs man
}




# fuzzy grep open via ag with line number
vg() {
  local file
  local line

  read -r file line <<<"$(ag --nobreak --noheading $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     vim $file +$line
  fi
}




fpdf () {
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

# v - open files in ~/.viminfo
v() {
  local files
  files=$(grep '^>' ~/.viminfo | cut -c3- |
          while read line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf-tmux -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}


function fcd() {
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
