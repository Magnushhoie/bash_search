# bash_search

#### 1. bash_notes.sh:
Bash search and edit note-taking system from the terminal using vim. Uses a combination of grep and vim to search a main note file or any file in ~/_References folder. Commands:
- ref keywords: Search for keywords in references.txt file
- refv keywords: Search references.txt and open at line in vim
- refv filename.txt: Create new note-taking file in reference folder
- **refv_papers keywords: Searches all pdfs in your scientific paper folder for keywords**
  - Hard-coded path. Set to paper folder used by your reference manager (EndNote, Mendeley, Zotero)
- ref_all keywords: Search for keywords in all files in reference folder (non file-specific)
- ref_allv keywords: Search content of all files and open any matched file at line in vim


#### 2. fuzzy_commands.sh:
Collection of fuzzy search find functions from: https://github.com/junegunn/fzf/wiki/examples
Provides extremely fast and powerful fuzzy search with useful commands. E.g. interactively searching and allowing editing of any number of files in a directory, searching all PDFs or notes on your computer, finding and killing processes and much more. Some commands:
- fif keywords (Find In Folder): Search all files in ANY folder for keywords, open in vim
- fh keyword (Find History): search bash history
- fda keyword (Find Directory All): Search for folders in current directory (infinite depth) and interactively change directory
- fcd (Fancy Change Directory): Interactive cd
- fkill (Find Kill): Search for all processes, kill selected one
- fb (Fnd Bookmark): Search all browser (Chrome/Safari/Firefox) bookmarks in buku
  - Automatically compile using: pip3 install --user buku; buku --sugest --ai
- fbhist (Find Browser HISTory): Search all browser (Safari/Chrome) history
  - Hard-set paths based on OSX. Change to own directories if want. Should also support firefox
- fman (Find Manual): Search bash manual
- **fpdf (Find PDF): Search any text in any pdf in folder, infinite depth**
  - Converts all pdfs in folder (infinite depth) to text (in cached directory)
- v (vim last used): Shows last used vim files

### 3. setup.sh:
- Installer for all dependencies. Coded for Mac OSX use.

### 4. optional files
- Collection of own .vim and .tmux configurations. Use at own risk...

