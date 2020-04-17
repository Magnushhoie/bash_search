#!/bin/bash
string2arg() {
    export arg_filename=$(cut -d":" -f1 <<< $1);
    export arg_linenum=$(cut -d":" -f2 <<< $1);
    min_offset=25
    let max_offset="min_offset*3"
    min=0
    if (($min_offset < $arg_linenum)); then
        let min="arg_linenum-$min_offset"
    fi
    let max="arg_linenum+$max_offset"
    bat --color=always --highlight-line $arg_linenum --style=header,grid,numbers --line-range $min:$max $arg_filename;
}

#function test_function ()
#{
#du -ch `find . -name "$1"` | sort -rh | fzf | realpath $(awk '{print $2}')
#}

function string2arg_filesize() {
  filename=$(echo $@ | awk '{print $3}')
  echo .$filename:
  fd ".+\.$filename$"
}

# | xargs test_function {}

#function test_function ()
#{
#du -ch `find . -name "$1"` | sort -rh
#}
