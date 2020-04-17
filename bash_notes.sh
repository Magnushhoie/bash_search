#!/bin/bash
ref_folder=$HOME/_References
papers_folder=$HOME/Desktop/Papers
PDF_TEXT=$HOME/_References/PDF_TEXT
mkdir -p ref_folder

local_name=$(uname -a | awk '{print $2}')
local_folder=$ref_folder/$local_name
bash_notes="$(realpath ${BASH_SOURCE[0]})"

function ref_help() # Show all functions in bash_notes.sh
{
echo $(realpath $bash_notes)
grep --color=always "^function " $bash_notes
}

function ref_helpv() # Edit bash_notes.sh
{
vim $bash_notes
}

ref_get_notefile() # Helper function for ref functions
{
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
  rg --pretty --no-line-number -B 8 -A 20 $2 "$filename" |
  rg --pretty --no-line-number -B 4 -A 10 "$2" |
  rg --pretty --no-line-number -B 4 -A 10 "$3" |
  rg --pretty --no-line-number -B 4 -A 10 "$4" |
  rg --pretty --no-line-number -B 4 -A 10 "$5" |
  rg --pretty --no-line-number -B 4 -A 10 "$6" |
  less -R
}


search_folder() {
folder=$1
script_files=($(find $folder -type f -not -path '*/\.*'))

{ for file in ${script_files[@]}; do
    rg --pretty --no-line-number -i -B 8 -A 20 $2 $file /dev/null;  done } |
rg --pretty --no-line-number -i -B 4 -A 10 "$2" |
rg --pretty --no-line-number -i -B 4 -A 10 "$3" |
rg --pretty --no-line-number -i -B 4 -A 10 "$4" |
rg --pretty --no-line-number -i -B 4 -A 10 "$5" |
rg --pretty --no-line-number -B 4 -A 10 "$6" |
less -R
}

function ref() # Search references.txt
{
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

function refv() # Search and edit references.txt in vim
{
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

function ref_fsearch() # Search and edit all reference files in Vim
{
current_dir=$PWD
# Use fuzzy search in folder from fuzzy_commands
cd $ref_folder
fsearch "$@"
cd $current_dir
}

function ref_all() # Search all reference files
{
notefile="$HOME/_References/references.txt"
folder=$(dirname $notefile)
script_files=($(find $folder -type f -not -path '*/\.*'))

search_folder $folder $@
}

function ref_papers() # Search all PDFs in paper folder (hardcoded)
{
current_dir=$PWD
# Use fuzzy search in folder from fuzzy_commands
cd $papers_folder
f_pdf $@
cd $current_dir
}

function ref_pdfs_fsearch()
{
cd $PDF_TEXT
fsearch $@
cd $current_dir
}

function ref_pdfs_fif()
{
cd $PDF_TEXT
fif $@
cd $current_dir
}

ref_add_pdfs()
{
  # Find all PDFs in folder and convert to txt in PDF_TEXT folder
fd ".pdf$" --exec pdftotext {} $PDF_TEXT/{/}.txt
#bash rename remove all spaces in filenames and foldernames
#find . -name "* *" -type d | rename 's/ /_/g'   find . -name "* *" -type f | rename 's/ /_/g'
}

#OUTDIR=$HOME/temp/test_pdf
#ref_add_pdfs() # Processes pdfs into txt in cache folder, for searching
#{
#find . -name "*.pdf" -exec pdftotext {} $OUTDIR \;
#}


#find /original -name "*.processme" -print0 | xargs -0 cp -s --target-directory=.
