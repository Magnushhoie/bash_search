# Fzf autocomplete
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Source awesome fuzzy search commands!
source ~/bash_search/*.sh
source ~/.autorun/*.sh
source ~/.autorun/z.sh
alias ll="exa"

alias sbp="source $HOME/.bash_profile"

vbp() {
vim $HOME/.bash_profile
}

lbp() {
less $HOME/.bash_profile
}

#Bash history
export HISTTIMEFORMAT="%h %d %H:%M:%S "
export HISTSIZE=50000
shopt -s histappend #Always append
PROMPT_COMMAND='history -a' #Store history immediately
export HISTCONTROL=ignoreboth:erasedups #Ignore start space, same as previous and erase duplicates
export HISTIGNORE="ls:ps:history:youtube" #Ignore commands
shopt -s cmdhist #One command per line
