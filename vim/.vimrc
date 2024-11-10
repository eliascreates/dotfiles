" === BASIC SETTINGS ===
" Enable syntax highlighting
syntax on

" Enable file type detection and automatic indentation
filetype plugin indent on

" Line numbering
let mapleader = " "
set number         " Show absolute line numbers
set relativenumber " Show relative line numbers for easier navigation

" Enable mouse support
set mouse=a

" Enable clipboard support (use system clipboard)
set clipboard=unnamedplus

" Enable incremental search
set incsearch
set hlsearch        " Highlight search results
set ignorecase      " Ignore case in search
set smartcase       " Case-sensitive search if uppercase is used

" Set indentation (adjust as needed)
set tabstop=4       " Number of spaces tabs count for
set shiftwidth=4    " Number of spaces for indentation
set expandtab       " Use spaces instead of tabs
set autoindent      " Copy indent from current line when starting a new line

" Enable cursor line for better focus on nothing
set cursorline

" Line wrapping and scroll offset
set wrap
set scrolloff=5     " Keep 5 lines visible above/below the cursor

" Enable persistent undo
set undofile        " Keep undo history across sessions

" === APPEARANCE ===
" Set a preferred colorscheme (install more themes if needed)
" Enable Gruvbox theme
set background=dark      " Or 'light' depending on preference

" Optional: Customize Gruvbox appearance
let g:gruvbox_contrast_dark = 'medium'  " You can choose 'hard', 'medium', or 'soft'

highlight Normal ctermbg=NONE guibg=#1c1c1c
autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=#1c1c1c
" Better visual spacing
set laststatus=2     " Always show the status line
set showcmd          " Show incomplete commands
set showmatch        " Highlight matching parentheses


" === PERFORMANCE ===
" Reduce time Vim waits after ESC key
set timeoutlen=500
set ttimeoutlen=10

" Faster key response
set updatetime=300

" === KEYMAPS ===
" Better split window navigation
nnoremap <C-h> <C-w>h     " Move to the left window
nnoremap <C-j> <C-w>j     " Move to the bottom window
nnoremap <C-k> <C-w>k     " Move to the top window
nnoremap <C-l> <C-w>l     " Move to the right window
" nnoremap <leader> :FZF<CR>


" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<CR>
noremap <leader>n :tabnew<CR>
noremap <leader>q :tabclose<CR>

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>

" Change cursor shape in insert mode
autocmd InsertEnter * silent !printf '\033[6 q'      
autocmd InsertLeave * silent !printf '\033[2 q'

" === PLUGIN MANAGEMENT ===
call plug#begin('~/.vim/plugged')

" A file explorer for Vim (NERDTree)
Plug 'preservim/nerdtree'
Plug 'morhetz/gruvbox'
" Status line
Plug 'vim-airline/vim-airline'

" Syntax highlighting for many languages
Plug 'sheerun/vim-polyglot'

" Auto-completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Git integration
Plug 'tpope/vim-fugitive'

" Auto pairs (for parentheses, quotes, etc.)

Plug 'jiangmiao/auto-pairs'

" Surround text objects easily
Plug 'tpope/vim-surround'

" Commenting tool
Plug 'scrooloose/nerdcommenter'

call plug#end()

" === PLUGIN CONFIGURATION ===

" === NERDTree ===
" Toggle NERDTree with backslash
map \ :NERDTreeToggle<CR>

" === Airline (status bar) ===
let g:airline#extensions#tabline#enabled = 1

" === COC (Language Server Protocol) ===
" For autocompletion, diagnostics, etc.
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-python']

" === Auto Pairs ===
let g:AutoPairsFlyMode = 1

" Change cursor shape in different modes
if exists('$WT_SESSION')
  let &t_SI = "\e[5 q"  " Insert mode: blinking line
  let &t_SR = "\e[4 q"  " Replace mode: blinking underline
  let &t_EI = "\e[1 q"  " Normal mode: blinking block
endif

colorscheme gruvbox

