#!/bin/bash

#Linuxbrew:
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
#test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
#test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
#echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

echo "Installing brew and pip ..."
#install brew
#bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#Install pip
#curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python get-pip.py

# Fuzzy finder!
brew install fzf

echo "Installing dependencies ..."
#Ensure updated
brew install vim
brew install less

# Fancy versions of bash utils
brew install bat
brew install ripgrep
brew install rga
brew install diff-so-fancy
brew install fzy
brew install fasd

echo "Installing buku, safari/chrome/firefox browser bookmark search"
# Search bookmarks from safari, chrome, firefox...
#pip3 install --user buku
#alias b='buku --suggest'
#b --ai

echo "Installing devdocs, offline programming documentation lookup"
# DevDocs for offline documentation lookup
#brew cask install devdocs

echo "Installing tldr, tldr lookup of bash commands"

echo "Sourcing fuzzy_commands.sh ..."
source fuzzy_commands.sh
echo "Done!"


#echo "Installing academic references fuzzy search"
# https://github.com/msprev/fzf-bibtex
#brew install bib-tool
#brew install go

#echo "Installing fast pdf searcher. Use in folder with pdfs"
#echo "Usage: p"
# Fast pdf finder
#brew install bellecp/fast-p/fast-pdf-finder
