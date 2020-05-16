#!/bin/bash
ref_folder=$HOME/_References
papers_folder=$HOME/Desktop/Papers

notefile="$ref_folder/references.txt"
PDF_PAPERS_FOLDER="/Users/admin/Library/Application Support/Mendeley Desktop/Downloaded"
PDF_PAPERS_DOWNLOAD_FOLDER="$ref_folder/pdfs/paper_download"
bash_notes="$(realpath ${BASH_SOURCE[0]})"

source fuzzy_commands.sh

ref_help() # Show all functions in bash_notes.sh
{
echo -e 'Your main note file is references.txt in folder ~/_References/.\nTo search or edit it, use "ref search terms here", or "refv". Both accept additional search keywords.'
echo -e "Tip: Use refv your_new_file.txt to create a new notefile. Search or edit it with ref / refv your_new_file\n"
echo $(realpath $bash_notes)
grep --color=always "^function " $bash_notes
}

function ref_list() # List note files in Reference folder
{
refv list
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
            then notefile=$ref_folder/$firstword
        fi
    fi

    # Print list of available files
    if [ $firstword = "-h" -o $firstword = "--help" -o $firstword = "list" ];
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
script_files=($(find $ref_folder -type f -not -path '*/\.*'))

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
script_files=($(find $ref_folder -maxdepth 1 -type f -not -path '*/\.*'))

{ for file in ${script_files[@]}; do
    rg --pretty --no-line-number -i -B 8 -A 20 $2 $file /dev/null;  done } |
rg --pretty --no-line-number -i -B 4 -A 10 "$2" |
rg --pretty --no-line-number -i -B 4 -A 10 "$3" |
rg --pretty --no-line-number -i -B 4 -A 10 "$4" |
rg --pretty --no-line-number -i -B 4 -A 10 "$5" |
rg --pretty --no-line-number -B 4 -A 10 "$6" |
less -R
}

function ref() # Search references.txt. Accepts search terms and/or files in search folder. E.g. ref datascience.txt Randomforest
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

function refv() # Search and edit references.txt in vim. Can create new files, e.g. refv datascience.txt
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
    then vim "$filename"
    else vim +":set hlsearch" +/$1.*$2.*$3.*$4.*$5 $filename
    fi
}

function ref_fsearch() # Interactive search and edit all reference files in Vim
{
current_dir=$PWD
# Use fuzzy search in folder from fuzzy_commands
cd $ref_folder
f_search "$@"
cd $current_dir
}

ref_fif()
{
current_dir=$PWD
cd $ref_folder
f_if "$@"
cd $current_dir
}

function ref_notes() # Search all files in top level directory _References
{
search_folder_top_only $ref_folder ${@:-"\s"}
}

function ref_all() # Search all files in _References, recursively
{
search_folder $ref_folder ${@:-"\s"}
}


get_pdfs() # Search all PDFs -> txt added to _References/PDF_ (ref_add_pdfs)
{
PDF_FOLDER=${1:-"$PDF_FOLDER"}
shift
search_terms=${@:-"\s"}
echo "$PDF_FOLDER"
echo "$search_terms"      
if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
local file
file=$(rga --max-count=1 --max-depth 2 --sort modified --max-filesize 1M --ignore-case --files-with-matches --no-messages "$1.*$2.*$3.$4.$5.$6" "$PDF_FOLDER" |
 fzf-tmux --delimiter / --with-nth -1 -e +m --preview="rga --ignore-case --pretty --context 10 "$1.*$2.*$3.$4.$5.$6" {}")

# Check if valid file and open
if [[ "$file" == *.* ]]; then
        if [[ "$file" == *.pdf.txt  ]]; then
                file=${file::${#file}-4}
        fi
        echo "$file" && open "$file"
fi

pdf_file=${file::${#file}-4}
}

ref_papers() # Search all PDFs -> txt added to _References/PDF_PAPERS (ref_add_pdfs ~/_References/PDF_PAPERS)
{
get_pdfs "$PDF_PAPERS_FOLDER" "$@"
}

ref_papers_download()
{
get_pdfs "$PDF_PAPERS_DOWNLOAD_FOLDER" "$@"
}

ref_pdfs_fsearch() # Interactive search all PDFs -> txt added to _References/PDF_TEXT
{
CURRENT_DIR="$PWD"
PDF_FOLDER=${1:-"$PDF_FOLDER"}
cd "$PDF_FOLDER"

f_if $@

cd "$CURRENT_DIR"
}

ref_add_pdfs() # Process all PDFs in folder (recursively) into txt into PDF_ or specified output folder. Required for ref_pdfs or ref_papers
{
#INDIR=${1:-'.'}
INPUT_PDF_FOLDER=${1:-"$PWD"}
OUTPUT_PDF_FOLDER=${2:-"$PDF_FOLDER"}
echo "Reading files from" $INPUT_PDF_FOLDER
echo "Outputting PDF -> txt in" "$OUTPUT_PDF_FOLDER"
mkdir -p "$PDF_FOLDER"

IFS=$'\n' read -r -d '' -a files < <(fd ".pdf$" $INPUT_PDF_FOLDER)
for file in "${files[@]}"; do

    # Check that file has valid characters
    if [[ "$file" =~ [a-zA-Z0-9] ]]; then
        # Replace spaces in new filename
        newfile=$(basename "$file")
        newfile=$(echo "$newfile" | sed -e 's/ /_/g')

        # Check if spaces-replaced filename is already present (processed)
        if [ $(fd ^"$newfile".txt$ "$OUTPUT_PDF_FOLDER") ]; then
          echo "Already present! :" "$newfile"

        # Convert pdf to txt for easy searching with f_search
        else
          echo "Adding ..." "$file"
          cp "$file" "$OUTPUT_PDF_FOLDER"/"$newfile"
          pdftotext "$file" "$OUTPUT_PDF_FOLDER"/"$newfile".txt #2>/dev/null
         fi
    fi; done
}

rename_files_remove_spaces() {
find . -name "* *" -type d
find . -name "* *" -type f
echo "Will rename all shown files/folders above by replacing spaces with _"
echo "(if empty, no renames will occur)"
read -p "Are you sure (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Renaming ..."
        find . -name "* *" -type d | rename 's/ /_/g'    # do the directories first
        find . -name "* *" -type f | rename 's/ /_/g'
else
        echo "Aborted"
fi
}
