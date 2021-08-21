#!/bin/bash
# Installs dependencies and adds source to ~/.bash_profile
# https://github.com/Magnushhoie/bash_search

script_path="${BASH_SOURCE[0]}"
script_dir="$(cd "$(dirname "$fuzzy_commands_path")" && pwd -P)"
source_file=$script_dir/fuzzy_commands.sh

echo -e
read -p "Install brew and pip (Necessary for installation of dependencies)? y/n " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
fi

echo -e
read -p "Brew install dependencies fzf coreutils fd bat ripgrep rga vim the_silver_searcher? y/n " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  $(brew --prefix)/opt/fzf/install
  brew install coreutils fd bat ripgrep rga vim
  brew install the_silver_searcher
fi

# If not sourced, ask to add to .bash_profile and .zshrc
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
  then
  echo -e
  read -p "Automatically add source fuzzy_commands.sh to .bash_profile and .zshrc? y/n " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]
        then
        echo -e "\nAdding source to .bash_profile and .zshrc ..."
        touch $HOME/.bash_profile
        touch $HOME/.zshrc

        LINE=$(echo -e "source $source_file")
        BASH_FILE=$(echo -e $HOME/.bash_profile)
        ZSH_FILE=$(echo -e $HOME/.zshrc)

        grep -qF -- "$LINE" "$BASH_FILE" || echo -e "$LINE" >> "$BASH_FILE"
        grep -qF -- "$LINE" "$ZSH_FILE" || echo -e "$LINE" >> "$ZSH_FILE"
    fi
fi

echo -e "\nDone! Please open a new terminal shell"