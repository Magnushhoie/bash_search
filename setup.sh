#!/bin/bash
echo "Bash note reference directory will be ~/_References/"

read -p "Install brew and pip (Necessary for installation of dependencies)? y/n " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
fi

echo -e "\nInstalling fzf fuzzy finder ..."
$(brew --prefix)/opt/fzf/install

echo -e "\nInstalling dependencies ..."
brew install coreutils fd vim bat ripgrep rga diff-so-fancy fzy fasd vim
brew install exa tree
brew install bellecp/fast-p/fast-pdf-finder # for searching PDFs
brew install tldr # look-up of bash-commands. E.g. tldr gzip
brew install the_silver_searcher # Extremely fast file searches with ag search_pattern

read -p "Install how-2 for searching StackExchange? E.g. how2 use loops in bash. y/n? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    brew install npm 
    npm install -g how-2 
fi

read -p "Install buku to search browser history and bookmarks? E.g. f_browser_bookmarks keywords  y/n? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    pip3 install --user buku
    echo "Creating buku database for browser bookmarks: buku --suggest --ai ..."
    buku --suggest --ai
fi

read -p "Automatically add source bash_notes.sh and fuzzy_commands.sh to .bash_profile? y/n " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Adding source to .bash_profile ..."
    script_dir=$(realpath $(dirname ${BASH_SOURCE[0]}))
    source_file=$script_dir/fuzzy_commands.sh

    LINE=$(echo 'source' $source_file)
    FILE=$(echo $HOME/.bash_profile)
    grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

    source_file=$script_dir/bash_notes.sh
    LINE=$(echo 'source' $source_file)
    FILE=$(echo $HOME/.bash_profile)
    grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

    #LINE=$(echo [ -f ~/.fzf.bash ] && source ~/.fzf.bash)
    #FILE=$(echo $HOME/.bash_profile)
    #grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

fi


read -p "Copy over vim configuration file? (Color highlighting of code, mouse support and other sane defaults...)  y/n? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp -r vim $HOME/.vim
    cp -r vimrc $HOME/.vimrc
fi


# Setting up references folder ...
echo "Setting up references folder in ~/_References/"
ref_folder=$HOME/_References
mkdir -p "$ref_folder"

FILE=$ref_folder/references.txt
if [ -f "$FILE" ]; then
    echo "$FILE exists"
else
    echo "$FILE does not exist. Creating new ..."
    cp references.txt $ref_folder/references.txt
fi

echo "Done! Please open a new terminal shell, or run source ~/.bash_profile"
echo -e "To get started try ref (search) or refv (search and edit in Vim)"
echo "Note: To exit refv (Vim), press Escape then write :q   ... to save and exit write :wq   ... :w = write, :q = quit
echo "Note: To exit ref \(less\) press q ... q = quit." 
echo "For overview of commands write  ref_help or f_help"
