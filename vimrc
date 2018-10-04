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
filetype plugin indent on

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
    
call plug#begin("~/.vim/plugged")
    "Fugitive Vim Github Wrapper
    Plug 'tpope/vim-fugitive'
    "add lightline
    Plug 'itchyny/lightline.vim'
    Plug 'joshdick/onedark.vim'
    
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

        
        "icons for nerdtree
        Plug 'ryanoasis/vim-devicons'

        Plug 'ncm2/ncm2'
        Plug 'roxma/nvim-yarp'


        " NOTE: you need to install completion
        " sources to get completions. Check
        " our wiki page for a list of sources:
        " https://github.com/ncm2/ncm2/wiki
        Plug 'ncm2/ncm2-bufword'
        Plug 'ncm2/ncm2-tmux'
        Plug 'ncm2/ncm2-path'
endif
call plug#end()

colorscheme onedark
let g:lightline = { 'colorscheme': 'onedark' }

" ctrl-n for nerdtree toggle
map <C-n> :NERDTreeToggle<CR>

"fzf mapping
map <Leader>t :FZF <Esc>
set laststatus=2


" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANTE: :help Ncm2PopupOpen for more
" information
set completeopt=noinsert,menuone,noselect

suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to
<ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup
" menu is visible, it only
" hides the menu. Use this mapping to close the
"menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ?
"\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup
" menu:
inoremap <expr> <Tab>
pumvisible() ? "\<C-n>" :
"\<Tab>"
inoremap <expr> <S-Tab>
pumvisible() ? "\<C-p>" :
"\<S-Tab>"
