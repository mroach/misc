"""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugins
""
"" Managed by vim-plug
""
call plug#begin(stdpath('data') . '/plugged')

" User interface
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'

" Theme
Plug 'sainnhe/sonokai'
Plug 'chriskempson/base16-vim'

" Language support
Plug 'plasticboy/vim-markdown'
Plug 'elixir-editors/vim-elixir'
Plug 'vim-ruby/vim-ruby'

" Development
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'

Plug 'tpope/vim-fugitive'

" Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Code completion
Plug 'dense-analysis/ale'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""
"" User interface
""
colorscheme sonokai

" Syntax highlighting
syntax enable

" Line numbers
set number

" Enable filetype detection and plugins and indent settings for it
filetype plugin indent on

" Show matching bracket/brace/paren when cursor is over one
set showmatch

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Display whitespace chars
set listchars=extends:>,precedes:<,space:·,tab:⇢-
set list

" Lines of context to show when scrolling at the top and bottom of the screen
set so=7

" Lightline config
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead',
  \ },
  \ }

"""""""""""""""""""""""""""""""""""""""""""""""""
"" Input, controls, navigation
""

" leader
let mapleader = ","

" tab navigation
nnoremap <leader>tp :tabp<CR>
nnoremap <leader>tn :tabn<CR>
" clear line and enter insert mode
nnoremap <leader>c dd0

" fzf
let g:fzf_command_prefix = 'Fzf'
map <C-p> :FzfFiles<CR>
map <C-f> :FzfRg<CR>

inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" nerdtree
map <C-k><C-b> :NERDTreeToggle<CR>
map <C-k><C-f> :NERDTreeFind<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""
"" Tabs, spaces, format
""

" Use spaces instead of tabs
set expandtab

set smarttab

" 1 tab = 2 spaces
set shiftwidth=2
set tabstop=2

set ai    " Auto indent
set si    " Smart indent
set wrap  " Wrap lines

" Line break on 500 chars
set lbr
set tw=500

" Show indentation guide
let g:indentLine_char = '⦙'

"""""""""""""""""""""""""""""""""""""""""""""""""
"" Files
""

set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""
" Language-specific config
"

" YAML: Force 2-space tabs for indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Ruby: Force 2-space tabs
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2

"""""""""""""""""""""""""""""""""""""""""""""""""
" Spell check
set spelllang=en
