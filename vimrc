" .vimrc
"
" Author: Luan Vicente <hi[at]idlua.me>

" Basics. -------------------------------------------------------------------{{{
" set shell=/bin/zsh\ --login

set spelllang=en_us
set nocompatible " Use Vim settings, rather than Vi settings.
set encoding=utf8
set history=100
set ruler
" set autochdir
" set clipboard=unnamed " Copy to OS clipboard.

set hidden " Allow Vim to manage multiple buffers effectively.

" Command line completions.
set wildmenu
set wildmode=list:longest

set ignorecase
set incsearch  " Search as characters are entered.
set hlsearch   " Highlight search results.

" 'Ehh.... No!' — Michael Richard Kyle Sr.
set nowrap
set nobackup
set noswapfile
set noerrorbells
set novisualbell

" Read filetype stuff.
filetype off
filetype plugin on
filetype indent on

" Vim faster.
set ttyfast
set ttyscroll=2
set lazyredraw " Don't redraw while executing macros - Good performance config.
set synmaxcol=128

" Basic visual definitions.
set relativenumber
set cursorline     " Highlight current line.
set showmatch      " Show matching brackets and parenthesis.
set colorcolumn=81 " Width ruller.
set laststatus=2   " Status bar always on.
set noshowcmd
set guifont=Monaco:h14

" Colorscheme.
syntax on " Enable syntax highlighting.
set t_Co=256
set background=dark
set termguicolors
colorscheme monokai

" Display tabs and trailing spaces.
set list
set listchars=tab:——
set listchars+=trail:⋅
set listchars+=nbsp:⣿
set listchars+=eol:↴
set listchars+=extends:»
set listchars+=precedes:«
" }}}
" Key mappings. -------------------------------------------------------------{{{
let mapleader = '-' " To do extra keys combinations.

nnoremap <leader>src :source %<CR>

" Select all text of current buffer.
nnoremap <leader>a ggvG$

" Intuitive splits navigation.
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-j> <C-w>j
noremap <C-h> <C-w>h

inoremap fj <ESC>
vnoremap fj <ESC>

" TABS.
nnoremap tn :tabnew<Space>
nnoremap tl :tabn<CR>
nnoremap th :tabp<CR>
" }}}
" Syntax and indentation. ---------------------------------------------------{{{
set autoindent
set smartindent
set smarttab
set expandtab " Spaces? Yeah! Tabs? No say it!

set pastetoggle=<F12>

" 1 TAB === 2 SPACES.
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Filetypes support.
autocmd BufRead,BufNewFile *.jade set filetype=pug
autocmd BufRead,BufNewFile *.pug  set filetype=pug
autocmd BufRead,BufNewFile *.sass set filetype=sass
autocmd BufRead,BufNewFile *.ejs set filetype=html

autocmd FileType gitcommit set colorcolumn=73
" }}}
" Folding settings. ---------------------------------------------------------{{{
set foldmethod=marker " I love this <3

autocmd FileType html setlocal foldmethod=indent
autocmd FileType css setlocal foldmethod=indent
autocmd FileType javascript setlocal foldmethod=indent
autocmd FileType sass setlocal foldmethod=indent
autocmd FileType markdown setlocal foldmethod=manual

" Disable folding.
autocmd BufRead,BufNewFile *.snippets set nofoldenable
autocmd BufRead,BufNewFile *.snippet set nofoldenable
" }}}
" Functions. ----------------------------------------------------------------{{{

" Automatically removing all trailing spaces.
autocmd BufWritePre * %s/\s\+$//e

" Autoindent. This is the magic, guys!
" augroup auto_indent
  " autocmd BufWritePre *.html :normal gg=G
  " autocmd BufWritePre *.css :normal gg=G
" augroup END

" Show syntax highlighting groups for word under cursor.
" Use Ctrl + w.
"
" I use this for develop my colorscheme for Vim :)
" You can see it in https://github.com/idlua/metropole.vim
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nnoremap <C-e> :call <SID>SynStack()<CR>

" This function clear all my registers.
" Thanks, mMontu: http://stackoverflow.com/a/26043227/6660244
function! <SID>ClearRegisters()
   redir => l:register_out
   silent register
   redir end
   let l:register_list = split(l:register_out, '\n')
   call remove(l:register_list, 0) " remove header (-- Registers --)
   call map(l:register_list, "substitute(v:val, '^.\\(.\\).*', '\\1', '')")
   call filter(l:register_list, 'v:val !~ "[%#=.:]"') " skip readonly registers
   for elem in l:register_list
      execute 'let @'.elem.'= ""'
   endfor
endfunction
nnoremap <C-i> :call <SID>ClearRegisters()<CR>

" Make views automatic to save my folds. This is awesome! <3
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview

" This is called each time a `|` character is entered.
" Thanks, tpope: https://gist.github.com/tpope/287147
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
" }}}
" Plugins. ------------------------------------------------------------------{{{

" Plugins list. -------------------------------------------------------------{{{
call plug#begin('~/.vim/plugins')
  Plug 'crusoexia/vim-monokai'
  Plug 'sCRooloose/nerdtree', { 'on': 'NERDTreeToggle' }
  " Plug 'airblade/vim-gitgutter'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'vim-scripts/tComment'
  Plug 'jiangmiao/auto-pairs'
  Plug 'w0rp/ale' " Bye bye Syntastic and your lags!
  Plug 'Yggdroot/indentLine'
  " Plug 'kien/ctrlp.vim'
  Plug 'wakatime/vim-wakatime'
  Plug 'kylef/apiblueprint.vim'

  " Snippets (plugin and depedencies).
  Plug 'tomtom/tlib_vim'
  Plug 'MarcWeber/vim-addon-mw-utils'
  Plug 'garbas/vim-snipmate'

  " Syntax.
  " Plug 'othree/html5.vim'
  Plug 'pangloss/vim-javascript'
  Plug 'tpope/vim-haml' " Sass/Scss syntax.
  Plug 'wavded/vim-stylus'
  Plug 'tpope/vim-fugitive'
call plug#end()
" }}}
" Plugins Settings. ----------------------------------------------------------{{{

" NERDTree.
let NERDTreeIgnore=['.git', '.bundle', 'node_modules']
let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1 " Show hidden files.
let NERDTreeShowLineNumbers=1

" Key mapping to toggle NERDTree.
noremap <leader>w :NERDTreeToggle<CR>

" Asynchronous Lint Engine.
" Navigate between errors quickly.
" nmap <silent> <C-k> <Plug>(ale_next_wrap)

" Keep the ALE sign gutter always open.
let g:ale_sign_column_always = 1

let g:ale_linters = {
\   'javascript': ['xo'],
\   'json': 'none'
\}

" Disable ALE for HTML files.
autocmd BufEnter *.html ALEDisable

" indentLine.
let g:indentLine_char = '┆'
let g:indentLine_color_term = 237
" }}}
"
