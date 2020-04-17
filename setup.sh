#!/bin/bash

#Linuxbrew:
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
#test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
#test -r ~/.bash_profile && echo -e "\neval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
#echo -e "\neval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

echo -e "\nInstalling brew and pip ..."
#install brew
#bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#Install pip
#curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python get-pip.py

echo -e "\nInstalling fzf fuzzy finder ..."
brew install fzf

echo -e "\nInstalling dependencies ..."
#Ensure updated
brew install fd vim less bat ripgrep rga diff-so-fancy fzy fasd

#echo -e "\nInstalling buku, safari/chrome/firefox browser bookmark search"
# Search bookmarks from safari, chrome, firefox...
#pip3 install --user buku
#alias b='buku --suggest'
#b --ai

#echo -e "\nInstalling devdocs, offline programming documentation lookup"
# DevDocs for offline documentation lookup
#brew cask install devdocs


# Dictionary look-up and translate
wget git.io/trans
chmod +x ./trans

echo -e "\nInstalling tldr, tldr lookup of bash commands"
pip install --user tldr

read -p "Automatically add source bash_notes.sh and fuzzy_commands.sh to .bash_profile? " -n 1 -r
    echo "Adding source to .bash_profile ..."
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    script_dir=$(dirname ${BASH_SOURCE[0]})
    source_file=$script_dir/fuzzy_commands.sh
    LINE=$(echo 'source' $source_file)
    FILE=$(echo $HOME/test.txt)
    grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

    source_file=$script_dir/bash_notes.sh
    LINE=$(echo 'source' $source_file)
    FILE=$(echo $HOME/test.txt)
    grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
fi

echo "Sourcing script files ..."
source $script_dir/fuzzy_commands.sh
source $script_dir/bash_notes.sh

echo "Done!"


#echo -e "\nInstalling academic references fuzzy search"
# https://github.com/msprev/fzf-bibtex
#brew install bib-tool
#brew install go

#echo -e "\nInstalling fast pdf searcher. Use in folder with pdfs"
#echo -e "\nUsage: p"
# Fast pdf finder
#brew install bellecp/fast-p/fast-pdf-finder
