#!/bin/bash
ref_folder=$HOME/_References
papers_folder=$HOME/Desktop/Papers

notefile=$ref_folder/references.txt
PDF_TEXT_FOLDER=$ref_folder/PDF_TEXT
PDF_PAPERS_TEXT_FOLDER=$ref_folder/PDF_PAPERS_TEXT

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
    firstword=${1:-"references"}

    # Search for .txt files in reference folder
    files=($ref_folder/*.txt)

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

search_folder_top_only() {
folder=$1
script_files=($(find $folder -maxdepth 1 -type f -not -path '*/\.*'))

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
     search_file $filename ${@:-"\s"}
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

ref_fif()
{
current_dir=$PWD
cd $ref_folder
fif "$@"
cd $current_dir
}

function ref_notes() # Search all reference files
{
search_folder_top_only $ref_folder ${@:-"\s"}
}

function ref_all() # Search all reference files
{
search_folder $ref_folder ${@:-"\s"}
}

function ref_papers() # Search all PDFs in paper folder (hardcoded)
{
CURRENT_DIR=$PWD
PDF_FOLDER=$PDF_PAPERS_TEXT_FOLDER
cd $PDF_FOLDER

search_terms=${@:-"\s"}
if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
local file
file=$(rga --max-count=1 --max-depth 2 --max-filesize 1M --ignore-case --files-with-matches --no-messages "$1.*$2.*$3.$4.$5.$6" |
 fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 "$1.*$2.*$3.$4.$5.$6" {}")
pdf_file=${file::${#file}-4}
open $pdf_file

cd $CURRENT_DIR
}


function ref_pdfs()
{
CURRENT_DIR=$PWD
PDF_FOLDER=$PDF_TEXT_FOLDER
cd $PDF_FOLDER

search_terms=${@:-"\s"}
if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
local file
file=$(rga --max-count=1 --max-depth 2 --max-filesize 1M --ignore-case --files-with-matches --no-messages "$1.*$2.*$3.$4.$5.$6" |
 fzf-tmux -e +m --preview="rga --ignore-case --pretty --context 10 "$1.*$2.*$3.$4.$5.$6" {}")
pdf_file=${file::${#file}-4}
open $pdf_file

cd $CURRENT_DIR
}

function ref_pdfs_fsearch()
{
CURRENT_DIR=$PWD
PDF_FOLDER=${1:-$PDF_TEXT_FOLDER}
cd $PDF_FOLDER

fif $@

cd $CURRENT_DIR
}


ref_add_pdfs() # Find all PDFs in folder and process into txt into PDF_TEXT or other output folder
{
#INDIR=${1:-'.'}
PDF_FOLDER=${1:-$PDF_TEXT_FOLDER}
echo "Outputting PDF -> txt in" $PDF_FOLDER
mkdir -p $PDF_FOLDER
# Find all PDFs in folder and convert to txt in PDF_TEXT_FOLDER folder
#fd ".pdf$" --exec pdftotext {} $PDF_TEXT_FOLDER/{/}.txt
#files=$(fd ".pdf$")
#for file in ${files[@]}; do

IFS=$'\n' read -r -d '' -a files < <(fd ".pdf$")
for file in "${files[@]}"; do

    # Check that file has valid characters
    if [[ "$file" =~ [a-zA-Z0-9] ]]; then
        # Replace spaces in new filename
        newfile=$(basename $file)
        newfile=$(echo "$newfile" | sed -e 's/ /_/g')

        # Check if spaces-replaced filename is already present (processed)
        if [ $(fd ^"$newfile".txt$ "$PDF_FOLDER") ]; then
          echo "Already present! :" "$newfile"

        # Convert pdf to txt for easy searching with fsearch
        else
          echo "Adding ..." "$file"
          cp "$file" $PDF_FOLDER/"$newfile"
          pdftotext "$file" $PDF_FOLDER/"$newfile".txt #2>/dev/null
         fi
    fi; done
}


#bash rename remove all spaces in filenames and foldernames
#find . -name "* *" -type d | rename 's/ /_/g'   find . -name "* *" -type f | rename 's/ /_/g'


#OUTDIR=$HOME/temp/test_pdf
#ref_add_pdfs() # Processes pdfs into txt in cache folder, for searching
#{
#find . -name "*.pdf" -exec pdftotext {} $OUTDIR \;
#}


#find /original -name "*.processme" -print0 | xargs -0 cp -s --target-directory=.
