#!/bin/bash

ref_folder=$HOME/_References
papers_folder=$HOME/Desktop/Papers
mkdir -p ref_folder
local_name=$(uname -a | awk '{print $2}')
local_folder=$ref_folder/$local_name

ref_get_notefile() {
# Searches note folder for notefile. Default is references.txt
# Alternative name given if first argument matches that basename excluding file extension
# New filename given if first argument ends in .txt
# List of available files given if first argument is "list"

    # Modify these three to change default file or folder
    notefile="$HOME/_References/references.txt"
    firstword=${1:-"references"}

    # Search for .txt files in reference folder
    folder=$(dirname $notefile)
    files=($folder/*.txt)

    # Look for alternative notefiles in folder if matches first argument
    for file in ${files[*]}; do
        file_shorthand=$(basename "${file%%.*}")
        if [ "$file_shorthand" = $firstword ];
            then notefile=$file
        fi;
        done

    # Override with NEW filename if first argument ends with *.txt !
    # First check lengths greater or equal than 4 to prevent error
    if [ ${#firstword} -ge 4 ];
        then if [ ${firstword: -4} = ".txt" ];
            then notefile=$folder/$firstword
        fi
    fi

    # Print list of available files
    if [ $firstword = "-h" -o $firstword = "-help" -o $firstword = "list" ];
        then for each in ${files[*]};
        do echo $each; done
    fi

    # Return notefile
    echo $notefile
}

search_file() {
filename=$1
  grep -i -B 30 -A 30 --color=always "$2" "$filename" |
  grep -i -B 30 -A 30 --color=always "$3" |
  grep -i -B 30 -A 30 --color=always "$4" |
  grep -i -B 30 -A 30 --color=always "$5" |
  grep -i -B 30 -A 30 --color=always "$6" |
  less -r
}

search_folder() {
folder=$1
script_files=($(find $folder -type f -not -path '*/\.*'))
{ for file in ${script_files[@]}; do
    grep -I -i -n -B 10 -A 30 --color=always $2 $file /dev/null; done } |
        grep -i -B 30 -A 30 --color=always "$2" |
        grep -i -B 30 -A 30 --color=always "$3" |
        grep -i -B 30 -A 30 --color=always "$4" |
        grep -i -B 30 -A 30 --color=always "$5" |
        less -r
}

ref() {
    filename=$(ref_get_notefile)

     # Check for alternative filename as first argument
     # If so, shift arguments so second+ becomes keyword
     alternative_filename=$(ref_get_notefile $1)
     if [ $filename != $alternative_filename ];
         then filename=$alternative_filename
         shift
     fi

     echo $filename
     search_file $filename $@
}

refv() {
# Opens up vim at first mention of keyword(s)
# Notefile is references.txt, unless another file found from first argument
     filename=$(ref_get_notefile)

    # Print list of available files
    if [ $1 = "-h" -o $1 = "-help" -o $1 = "list" ];
        then echo -e "\nAvailable files:"
             for each in $(ref_get_notefile $1);
             do ls -ltrh $each; done

             echo -e "\nMain reference file: \t" $filename
             echo -e "Search or edit: \t refv keyword1 keyword2 ..."
             echo -e "Alternative file: \t refv different_name"
             echo -e "Add new file:   \t refv new_file.txt"
             return [n]
    fi

     # Check for alternative filename as first argument
     # If so, shift arguments so second+ becomes keyword
     alternative_filename=$(ref_get_notefile $1)
     if [ $filename != $alternative_filename ];
         then filename=$alternative_filename
         shift
     fi

    # Run vim on keywords
    if [ -z $1 ];
    then vim $filename
    else vim +":set hlsearch" +/$1.*$2.*$3.*$4.*$5 $filename
    fi
}

refv_all() {
current_dir=$PWD
# Use fuzzy search in folder from fuzzy_commands
cd $ref_folder
fif "$@"
cd $current_dir
}

ref_all () {
notefile="$HOME/_References/references.txt"
folder=$(dirname $notefile)
script_files=($(find $folder -type f -not -path '*/\.*'))

{ for file in ${script_files[@]}; do
    grep -i -B 10 -A 100 --color=always $1 $file; done } |
        grep -i -B 30 -A 100 --color=always "$2" |
        grep -i -B 30 -A 100 --color=always "$3" |
        grep -i -B 30 -A 100 --color=always "$4" |
        grep -i -B 30 -A 100 --color=always "$5" |
        less -r
}

ref_papers() {
current_dir=$PWD
# Use fuzzy search in folder from fuzzy_commands
cd $papers_folder
fpdf $@
cd $current_dir
}

ref_pdfs_all() {
current_dir=$PWD
cd $HOME
fpdf $@
cd $current_dir
}

vbp() {
vim $HOME/.bash_profile
}

lbp() {
less $HOME/.bash_profile
}
