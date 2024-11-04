" - General specifications -----------------------------------------------------------------------------------
if exists('g:vscode')
    " VSCode extension
    "" Is it enabled when replacing any words like '%s/old_word/new_word/g'?
    "set incsearch
    "set hlsearch
    "set ruler          " Already enabled by default?


    " Visualize tags, tails etc. This configurations are not working in VSCode.
    "set list
    "set listchars=tab:^\ ,trail:･,nbsp:%,extends:>,precedes:<

    set virtualedit=all
else
    " ordinary Neovim
    scriptencoding utf-8
    set encoding=utf-8
    set number
    set incsearch
    set hlsearch

    set showmatch      " Already enabled by default?
    set wrapscan       " Already enabled by default?
    set hidden         " Already enabled by default?
    set history=10000  " It should be less or equals to 10,000.

    set ruler          " It should be set combined with "set rulerformat".
                       " Already enabled by default?
    set rulerformat=%-14.(%l,%c%V%)\ %P

    " Visualize tags, tails etc
    set list
    set listchars=tab:^\ ,trail:･,nbsp:%,extends:>,precedes:<

    set autoindent     " Already enabled by default?

    set conceallevel=0  " Disable the auto-hide feature in json-vim (https://github.com/spf13/spf13-vim/issues/375#issuecomment-18810973)

    set virtualedit=block
endif

set ignorecase   " Ignore case when searching
set whichwrap=h,l

set clipboard=unnamedplus    " user the system clipboard

set expandtab
"set noexpandtab		" Use tab as tab
set tabstop=4
set shiftwidth=4    " Number of spaces to use for each step of (auto)indent.  Used for |'cindent'|, |>>|, |<<|, etc.
set softtabstop=4   " Spaces feel like real tabs

set helplang=en

set wildmenu                    " Is this enabled on VSCode?
set wildmode=longest:full,full  " Is this enabled on VSCode?


set mouse=a

set autoread    " enable auto load the file (depending on your platform)

" Preferences of each files
autocmd FileType yaml               setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript         setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript         setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescriptreact    setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype html               setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

set cindent
filetype plugin indent on
set cinkeys-=0#
set indentkeys-=0#
autocmd FileType * set cindent      " Some file types override it

let mapleader = ";"                 " Change leader for vim plugins from '\'

if &diff                             " only for diff mode/vimdiff
  set diffopt=filler,context:1000000 " filler is default and inserts empty lines for sync
endif

" - Additional keymaps ---------------------------------------------------------------------------------------
if exists('g:vscode')
    " Key maps are declared in keyconfig.json in VSCode
else
    " bind key map
    " save, quit, force quit
    nnoremap <Space>w  :<C-u>w<CR>
    nnoremap <Space>W  :<C-u>w !sudo tee % >/dev/null<CR>
    nnoremap <Space>q  :<C-u>q<CR>
    nnoremap <Space>Q  :<C-u>q!<CR>

    " open current file as root
    nnoremap <Space>s  :<C-u>e sudo:%<CR>

    " passage caret head or last in normal and visual mode.
    noremap <Space>h  ^
    noremap <Space>h  0
    noremap <Space>l  $


    " select all text
    nnoremap <Space>a ggVG

    " insert blank line
    nnoremap <Space>o  :<C-u>for i in range(v:count1) \| call append(line('.'), '') \| endfor<CR>
    nnoremap <Space>O  :<C-u>for i in range(v:count1) \| call append(line('.')-1, '') \| endfor<CR>

    " key map about tab
    nnoremap <silent> tt  :<C-u>tabe<CR>
    nnoremap <C-p>  gT
    nnoremap <C-n>  gt

    " invisible highlight aster highlight search(Ctrl + C * 2)
    nnoremap  <C-c><C-c> :<C-u>nohlsearch<cr><Esc>

    inoremap jk  <Esc>

    " Copy on clipboard in visual mode. Require vim-gtk
    " $ sudo apt-get install vim-gtk
    vnoremap <C-c>  "+y
    vnoremap <C-v>  "+p

    " - Tag page settings ----------------------------------------------------------------------------------------
    " reference
    " http://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
    nnoremap s, <C-w><
    nnoremap s. <C-w>>

    nnoremap sj <C-w>j
    nnoremap sk <C-w>k
    nnoremap sl <C-w>l
    nnoremap sh <C-w>h
    nnoremap sJ <C-w>J
    nnoremap sK <C-w>K
    nnoremap sL <C-w>L
    nnoremap sH <C-w>H
endif
