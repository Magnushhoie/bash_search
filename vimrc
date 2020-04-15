
filetype on
autocmd FileType python nnoremap <buffer> <F9> :exec '!clear; python' shellescape(@%, 1)<cr>

set backspace=indent,eol,start
set background=dark
colorscheme elflord "previous slate
set number "line numbers

set nocompatible
filetype off

" Special stuff
set ignorecase
"set smartcase
:nnoremap <C-e> <C-w> "Remap ctrl + w (closes tab in osx) to be able to switch vim tabs

"set ttyfast
set ttymouse=xterm2
set mouse=a

set t_Co=256
""python3 from powerline.vim import setup as powerline_setup
""python3 powerline_setup()
""python3 del powerline_setup

set foldcolumn=3

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Simple plugin
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" fzf fuzzy search for vim
" If installed using Homebrew
set rtp+=/usr/local/opt/fzf

" Autocomplete TabNine
"Plugin 'zxqfl/tabnine-vim'

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" The bundles you install will be listed here
Plugin 'tmhedberg/SimpylFold'
let g:SimpylFold_docstring_preview=1

"Plugin 'janko-m/vim-test'
"nmap <silent> <leader>t :TestNearest<CR>
"nmap <silent> <leader>T :TestFile<CR>
"nmap <silent> <leader>a :TestSuite<CR>
"nmap <silent> <leader>l :TestLast<CR>
"nmap <silent> <leader>g :TestVisit<CR>

Plugin 'jeetsukumaran/vim-indentwise'
Plugin 'vim-scripts/indentpython.vim'
"Plugin 'Konfekt/FastFold'

call vundle#end()            " required
filetype plugin indent on

let python_highlight_all=1
syntax on
set encoding=utf-8

set backupdir=~/vimfiles/tmp,.
set directory=~/vimfiles/tmp,.

set pastetoggle=<F10>
set expandtab

au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=119 expandtab autoindent fileformat=unix
au BufNewFile,BufRead *.cpp set tabstop=2 softtabstop=2 shiftwidth=2 textwidth=119 expandtab autoindent fileformat=unix
au BufNewFile,BufRead *.c set tabstop=2 softtabstop=2 shiftwidth=2 textwidth=119 expandtab autoindent fileformat=unix
au BufNewFile,BufRead *.h set tabstop=2 softtabstop=2 shiftwidth=2 textwidth=119 expandtab autoindent fileformat=unix
au BufNewFile,BufRead *.hpp set tabstop=2 softtabstop=2 shiftwidth=2 textwidth=119 expandtab autoindent fileformat=unix
setlocal foldmethod=expr

au BufNewFile,BufRead *.js,*.html,*.css: set tabstop=2 softtabstop=2 shiftwidth=2
set list
set listchars=tab:>-

map <C-n> :enew
map <C-o> :e . <Enter>
map <C-s> :w <Enter>
map <C-c> y
"map <C-v> p
"map <C-x> d
map <C-z> u
map <C-t> :tabnew <Enter>
map <C-i> >>
map <C-w> :close <Enter>
map <C-W> :q! <Enter>
map <C-f> /
map <F3> n

let mapleader = "\\"
map <Leader>ve :sp $HOME/.vimrc<CR>
map <Leader>vs :source $HOME/.vimrc<CR>

map g] :stj<CR>
map <Leader>= <C-W>=
map <Leader><CR> <C-W>_
map <Leader><Up> <C-W><Up><C-W>_
map <Leader><Down> <C-W><Down><C-W>_
map <Leader>1 99<C-W><Up><C-W>_
map <Leader>2 99<C-W><Up>1<C-W>j<C-W>_
map <Leader>3 99<C-W><Up>2<C-W>j<C-W>_
map <Leader>4 99<C-W><Up>3<C-W>j<C-W>_
map <Leader>5 99<C-W><Up>4<C-W>j<C-W>_
map <Leader>d Oimport pdb; pdb.set_trace()^[

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-]> g<C-]>
