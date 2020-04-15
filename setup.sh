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
brew install vim
brew install less
brew install bat
brew install ripgrep
brew install rga
brew install diff-so-fancy
brew install fzy
brew install fasd

#echo -e "\nInstalling buku, safari/chrome/firefox browser bookmark search"
# Search bookmarks from safari, chrome, firefox...
#pip3 install --user buku
#alias b='buku --suggest'
#b --ai

#echo -e "\nInstalling devdocs, offline programming documentation lookup"
# DevDocs for offline documentation lookup
#brew cask install devdocs

echo -e "\nInstalling tldr, tldr lookup of bash commands"
pip install --user tldr

echo -e "\nSourcing fuzzy_commands.sh ..."
source fuzzy_commands.sh

echo -e "Adding source to .bash_profile"
source_file=$PWD/fuzzy_commands.sh
LINE=$(echo 'source' $source_file)
FILE=$(echo $HOME/test.txt)
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
echo -e "\nDone!"


#echo -e "\nInstalling academic references fuzzy search"
# https://github.com/msprev/fzf-bibtex
#brew install bib-tool
#brew install go

#echo -e "\nInstalling fast pdf searcher. Use in folder with pdfs"
#echo -e "\nUsage: p"
# Fast pdf finder
#brew install bellecp/fast-p/fast-pdf-finder
