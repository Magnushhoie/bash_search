# bash_search

Collection of BASH scripts for searching text files, folders and PDFs interactively from the terminal.

Most functionality relies on fuzzy search functions using fzf (https://github.com/junegunn/fzf) for searching and interacting with content in any folder.

Installation of dependencies:
```bash
bash setup.sh
```


### setup.sh:
- Run bash setup.sh for installation of all dependencies using homebrew/linuxbrew and addition of aliases to .bash_profile
- Tested on macOS Mojave and Ubuntu 18.04.

#### fuzzy_commands.sh:
Series of search scripts that provide extremely fast and powerful fuzzy search with useful commands. These can potentially search your entire computer for text in minutes.
E.g. **interactively searching and allowing editing of any number of files in a directory, searching all PDFs or notes on your computer, finding and killing processes** and much more.

Compiled from https://github.com/junegunn/fzf/wiki/examples and others, with some small tweaks for personal use.

Bash fuzzy search commands. All are interactive using FZF:
- f_search (Find search): Search files by lines on your computer, from current directory. Very powerful.
- f_if (Find In Folder): Variant of the above. Cleaner presentation of search results. Configure max-depth to search deeper.
- f_folders: Search folders on your computer, from current directory. 
- f_files: Shows contents of all files in the current directory
- f_cd: Interactive cd for browsing directories.
- f_history (Find BASH history): search your bash command history. Alternatively, use ctrl + r to search directly in the terminal using FZF.
- f_git: Interactive search of git history
- f_kill (Find Kill): Search all processes, kill selected one
- f_man (Find Manual): Search bash manual
- f_pdf (Find PDF): Search any text in any pdf in folder, infinite depth. Enter to open file.
- f_vim (vim last used): Shows / selects last opened vim files

In addition, if keybindings are enabled try these FZF shortcuts:
- Ctrl + r: Search bash history
- Ctrl + t: Search files


