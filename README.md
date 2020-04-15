# bash_search

Personal reference and note-taking system with search and edit directly in terminal. Includes combination of extremely powerful fuzzy search functions using fzf (https://github.com/junegunn/fzf) for searching and interacting with content in any folder.

### Example of use:

https://terminalizer.com/view/ef4b2b193819

Installation of dependencies:
```bash
bash setup.sh
```

Add to .bash_profile or .bashrc:
```bash
source bash_search/fuzzy_commands.sh
source bash_search/bash_notes.sh
```

#### 1. bash_notes.sh:
Bash note-taking system with easy search and editing in place, directly from the terminal using vim.
Uses a combination of grep and vim to search a main note file or any file in ~/_References folder.

Commands:
- ref keywords: Search for keywords in references.txt
- refv keywords: Search references.txt and open at line in vim
- refv filename.txt: Create new note file
- **ref_papers: Interactively searches all pdfs in your scientific paper folder for keywords**
  - Note: Hard-coded path. Set to paper folder used by your reference manager (EndNote, Mendeley, Zotero)
- ref_all: Search for keywords in all files in reference folder (non file-specific)
- ref_allv: Interactively searches content of all files in reference folder and allows editing any matched file at line in vim


#### 2. fuzzy_commands.sh:
Series of search scripts that provide extremely fast and powerful fuzzy search with useful commands.
E.g. **interactively searching and allowing editing of any number of files in a directory, searching all PDFs or notes on your computer, finding and killing processes** and much more.

Compiled from https://github.com/junegunn/fzf/wiki/examples and others, with some small tweaks for personal use.

Bash fuzzy search commands:
- fif (Find In Folder): Search all files in ANY folder for keywords, open in vim
- fh (Find BASH History): search bash history
- fda (Find Directory All): Search for folders in current directory (infinite depth) and interactively change directory
- fcd (Fancy Change Directory): Interactive cd
- fkill (Find Kill): Search for all processes, kill selected one
- fman (Find Manual): Search bash manual

Specific applications:
- fpdf (Find PDF): Search any text in any pdf in folder, infinite depth
  - Converts all pdfs in folder (infinite depth) to text (in cached directory)
- fbhist (Find Browser HISTory): Search your entire browser (Safari/Chrome) history(es)
  - Hard-set paths based on OSX. Change to own directories if want. Should also support firefox with modification
- fb (Find Bookmark): Search all browser (Chrome/Safari/Firefox) bookmarks compiled in buku database
   - Easily set-up using: pip3 install --user buku; buku --suggest --ai
   - https://github.com/jarun/buku
- v (vim last used): Shows / selects last opened vim files

### 3. setup.sh:
- Installer for all dependencies. Coded for Mac OSX use.

### 4. optional files
- Collection of own .vim and .tmux configurations. Use at own risk...

