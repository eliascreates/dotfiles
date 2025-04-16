" =============================================================================
" Enhanced Vim Configuration
" =============================================================================

" === Plugin Management ===
call plug#begin('~/.vim/plugged')

" --- Appearance ---
Plug 'joshdick/onedark.vim'              " One Dark theme
Plug 'morhetz/gruvbox'                   " Gruvbox theme
Plug 'sainnhe/gruvbox-material'          " Gruvbox Material
Plug 'dracula/vim', { 'as': 'dracula' }  " Dracula theme
Plug 'ayu-theme/ayu-vim'                 " Ayu theme
Plug 'arcticicestudio/nord-vim'          " Nord theme
Plug 'rakr/vim-one'                      " One theme
Plug 'tomasr/molokai'                    " Molokai theme
Plug 'nanotech/jellybeans.vim'           " Jellybeans theme
Plug 'ghifarit53/tokyonight-vim'         " Tokyo Night theme
Plug 'sainnhe/sonokai'                   " Sonokai theme
Plug 'vim-airline/vim-airline'           " Status line
Plug 'vim-airline/vim-airline-themes'    " Airline themes
Plug 'ryanoasis/vim-devicons'            " File icons
Plug 'machakann/vim-highlightedyank'

" --- Functionality ---
Plug 'preservim/nerdtree'                " File explorer
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Completion
Plug 'tpope/vim-fugitive'                " Git integration
Plug 'jiangmiao/auto-pairs'              " Auto pairs
Plug 'tpope/vim-surround'                " Surround text
Plug 'scrooloose/nerdcommenter'          " Comments
Plug 'sheerun/vim-polyglot'              " Language support
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy finder
Plug 'junegunn/fzf.vim'                  " FZF integration
Plug 'easymotion/vim-easymotion'         " Easy motion
" Plug 'roxma/vim-tmux-clipboard'          " Improved clipboard support

call plug#end()

" === General Settings ===
set nocompatible              " Modern Vim
syntax enable                 " Syntax highlighting
filetype plugin indent on     " File type detection
set encoding=UTF-8            " UTF-8 encoding
set hidden                    " Allow hidden buffers
set number relativenumber     " Hybrid line numbers
set mouse=a                   " Enable mouse support
set clipboard=unnamedplus     " System clipboard
set updatetime=300            " Faster completion
set timeoutlen=500            " Faster key response
set backspace=indent,eol,start " Better backspace

" === Search Settings ===
set incsearch                " Incremental search
set hlsearch                 " Highlight search
set ignorecase               " Case insensitive
set smartcase                " Smart case sensitivity

" === Indentation ===
set autoindent               " Auto indent
set smartindent              " Smart indent
set expandtab                " Spaces instead of tabs
set tabstop=4                " Tab width
set softtabstop=4            " Soft tab width
set shiftwidth=4             " Indent width

" === Visual Settings ===
set termguicolors            " True color support
set cursorline               " Highlight current line
set wrap                     " Wrap lines
set scrolloff=5              " Scroll offset
set sidescrolloff=5          " Horizontal scroll offset
set showmatch                " Show matching brackets
set laststatus=2             " Always show status line
set noshowmode               " Hide mode (shown in airline)
set signcolumn=yes           " Always show sign column

" === Persistence ===
set undofile                 " Persistent undo
set undodir=~/.vim/undodir   " Undo directory
set backup                   " Enable backup
set backupdir=~/.vim/backup  " Backup directory
set directory=~/.vim/swap    " Swap directory

" Create necessary directories
silent !mkdir -p ~/.vim/{undodir,backup,swap}

" Customize yank highlight
let g:highlightedyank_highlight_duration = 500 " Highlight duration in milliseconds
highlight HighlightedyankRegion cterm=reverse gui=reverse

" Fallback yank highlighting for terminals that don't support the plugin
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=500}
augroup END

" === Cursor Settings ===
" Change cursor shape based on mode
let &t_SI = "\e[6 q"         " Insert mode: vertical bar
let &t_SR = "\e[4 q"         " Replace mode: underscore
let &t_EI = "\e[2 q"         " Normal mode: block

" === Gruvbox Material Theme Configuration ===
set background=dark
let g:gruvbox_material_background = 'medium'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_diagnostic_line_highlight = 1
let g:gruvbox_material_enable_italic = 1
colorscheme gruvbox-material

" === Airline Configuration ===
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='gruvbox_material'

" === Windows-specific Clipboard Settings ===
if has('win32') || has('win64')
    " Explicitly set clipboard to use Windows clipboard
    set clipboard=unnamed,unnamedplus
endif

" === NERDTree Configuration ===
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
" Map backslash to toggle NERDTree in normal mode
map <silent> \ :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" === Key Mappings ===
let mapleader = " "        " Space as leader key

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Tab navigation
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<CR>

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>

" Improved Search and Escape Shortcuts
" Use escape to clear search highlighting
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Additional Convenient Shortcuts
" Quick save without leaving normal mode
nnoremap <leader>s :w<CR>

" Quick reload of vimrc
nnoremap <leader>rv :source $MYVIMRC<CR>

" Open vimrc quickly
nnoremap <leader>ec :e $MYVIMRC<CR>

" Easier indentation in visual mode
vnoremap < <gv
vnoremap > >gv

" Move lines up and down in normal and visual mode
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" === COC Configuration ===
let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-python',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-prettier'
    \ ]

" Use tab for trigger completion
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> auto-select the first completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" === Auto Commands ===
" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Remember cursor position
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif

" === FZF Configuration ===
nnoremap <leader>ff <cmd>Files<cr>
nnoremap <leader>fg <cmd>Rg<cr>
nnoremap <leader>fb <cmd>Buffers<cr>

" === Custom Functions ===
" Toggle between light and dark background
function! ToggleBackground()
    if &background == "dark"
        set background=light
        let g:gruvbox_material_background = 'soft'
    else
        set background=dark
        let g:gruvbox_material_background = 'medium'
    endif
    colorscheme gruvbox-material
endfunction
nnoremap <leader>bg :call ToggleBackground()<CR>

" Toggle relative line numbers
function! ToggleRelativeNumber()
    if &relativenumber
        set norelativenumber
    else
        set relativenumber
    endif
endfunction
nnoremap <leader>rn :call ToggleRelativeNumber()<CR>

" === Terminal and Clipboard Setup ===
" For better copy-paste in Windows:
if has('win32') || has('win64')
    let g:clipboard = {
          \   'name': 'win32yank',
          \   'copy': {
          \     '+': 'win32yank.exe -i --crlf',
          \     '*': 'win32yank.exe -i --crlf',
          \   },
          \   'paste': {
          \     '+': 'win32yank.exe -o --lf',
          \     '*': 'win32yank.exe -o --lf',
          \   },
          \   'cache_enabled': 1,
          \ }
endif
