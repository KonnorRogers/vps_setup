set nocompatible    "run in vim mode
set expandtab       "expand tabs into spaces
set autoindent      "auto-indent new lines
set smartindent     "return ending brackets to proper locations
set softtabstop=4   "indentation level of soft-tabs
set tabstop=4       "indentation leves of normal tabs
set shiftwidth=4    "how many columns to re-indent with << and >>
set showmatch       "show matching brackets
set ruler           "show cursor position at all times
set nohls           "don't highlight the previous search term
set number          "turn on line numbering
set wrap            "turn on visual word wrapping
set linebreak       "only break lines on 'breakat' characters
syntax on           "turn on syntax highlighting
set nobackup        "no backups
set nowritebackup   "no backup file while editing
set noswapfile      "no creation of swap files
set noundofile      "prevents extra files from being created

if has('nvim') || has('termguicolors')
  set termguicolors
endif

if has("autocmd")
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
\| exe "normal g'\"" | endif
endif
 
augroup filetypedetect 
  au! BufRead,BufNewFile *nc setfiletype nc "http://www.vim.org/scripts/script.php?script_id=1847
  "html.ep now handled by https://github.com/yko/mojo.vim
  autocmd BufNewFile,BufReadPost *.ino,*.pde set filetype=cpp
augroup END 

"strip trailing whitespace from certain files
autocmd BufWritePre *.conf :%s/\s\+$//e
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.css :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e
autocmd BufWritePre *.rb :%s/\s\+$//e

:set bs=2 "fix backspace on some consoles


" Will install plugins if not detected
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if has('nvim')
    " Will install plugins if not detected
    if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
        silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        "autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
    
    call plug#begin("~/.config/nvim/plugged")
        Plug 'brooth/far.vim'
        "Fugitive Vim Github Wrapper
        Plug 'tpope/vim-fugitive'
        "Bundler wrapper
        Plug 'tpope/vim-bundler'
        "Rapid file search
        Plug 'skalnik/vim-vroom'
        "Tab complete ends
        Plug 'tpope/vim-endwise'
        "nerdtree file explorer
        Plug 'scrooloose/nerdtree'
        "vim ruby
        Plug 'vim-ruby/vim-ruby'
        "challenger deep colorscheme
        Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
        "add lightline
        Plug 'itchyny/lightline.vim'
        "add ctrlp for file finding
        Plug 'https://github.com/ctrlpvim/ctrlp.vim.git'
    call plug#end()
else
    call plug#begin("~/.vim/plugged")
        "Challenger-deep colorscheme, forked version with updates for mintty
        Plug 'https://github.com/ParamagicDev/vim.git', { 'as': 'challenger-deep' }
        "add lightline
        Plug 'itchyny/lightline.vim'
        "Add nerdtree
        Plug 'scrooloose/nerdtree'
    call plug#end()
endif

if !has('gui_running')
  set t_Co=256
endif

colorscheme challenger_deep
" ctrl-n for nerdtree toggle
map <C-n> :NERDTreeToggle<CR>

" set lightline to challenger deep
let g:lightline = { 'colorscheme': 'challenger_deep'}
