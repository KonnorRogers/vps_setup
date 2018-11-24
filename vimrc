set nocompatible    "run in vim mode

" Will install plugins if not detected
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
    
call plug#begin("~/.vim/plugged")
    "Fugitive Vim Github Wrapper
    Plug 'tpope/vim-fugitive'
    "add lightline
    Plug 'itchyny/lightline.vim'
    Plug 'flazz/vim-colorschemes'
    
    if has('nvim')
        "PlugInstall and PlugUpdate will clone fzf in ~/.fzf and run install script
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
        "linting
        Plug 'w0rp/ale'
        "nerdtree file explorer
        Plug 'scrooloose/nerdtree'
        "tpope plugins
        Plug 'vim-ruby/vim-ruby'
        Plug 'tpope/vim-bundler'
        Plug 'tpope/vim-endwise'
        Plug 'tpope/vim-rails'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-ragtag'

        Plug 'jiangmiao/auto-pairs'
        Plug 'ngmy/vim-rubocop'
    endif
call plug#end()


set expandtab       "expand tabs into spaces
set autoindent      "auto-indent new lines
set smartindent     "return ending brackets to proper locations
set showmatch       "show matching brackets
set ruler           "show cursor position at all times
set nohls           "don't highlight the previous search term
set number          "turn on line numbering
set wrap            "turn on visual word wrapping
set linebreak       "only break lines on 'breakat' characters
set tabstop=2 " when indenting with '>', use 4 spaces width
set shiftwidth=2 " On pressing tab, insert 4 spaces
set expandtab
syntax on           "turn on syntax highlighting
set nobackup        "no backups
set nowritebackup   "no backup file while editing
set noswapfile      "no creation of swap files
set noundofile      "prevents extra files from being created
filetype plugin indent on
filetype on
filetype indent on
set backspace=indent,eol,start
" 'matchit.vim' is built-in so let's enable it!
" " Hit '%' on 'if' to jump to 'else'.
runtime macros/matchit.vim
set wildmenu
set incsearch
set hidden
set lazyredraw

if has('nvim') || has('termguicolors')
  set termguicolors
endif

if !has('gui_running')
  set t_Co=256
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

"removes auto-commenting when hitting <CR>
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"strip trailing whitespace from certain files
autocmd BufWritePre *.conf :%s/\s\+$//e
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.css :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e
autocmd BufWritePre *.rb :%s/\s\+$//e

:set bs=2 "fix backspace on some consoles

" set spacing on ruby files
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal expandtab shiftwidth=2 tabstop=2


colorscheme apprentice
let g:lightline = { 'colorscheme': 'wombat' }

" ctrl-n for nerdtree toggle
map <C-n> :NERDTreeToggle<CR>
map <Leader>r :NERDTreeRefreshRoot<Esc>

"fzf mapping
map <Leader>t :FZF <Esc>
set laststatus=2

" rubocop mapping
nmap <Leader>ra :RuboCop -a<CR>

" ragtag recomendded keybinding
" "jumps to next line in insert
inoremap <M-o> <Esc>o 

" moves down a line from where you are
inoremap <C-j>       <Down>
let g:ragtag_global_maps = 1 "available globally

function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction

map <Leader>rn :call RenameFile()<cr>
