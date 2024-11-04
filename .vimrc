" - General specifications -----------------------------------------------------------------------------------
if exists('g:vscode')
    " VSCode extension
    "" Is it enabled when replacing any words like '%s/old_word/new_word/g'?
    "set incsearch
    "set hlsearch
    set ignorecase   " Ignore case when searching
    set whichwrap=h,l
    "set ruler          " Already enabled by default?

    set clipboard=unnamedplus    " user the system clipboard

    " Visualize tags, tails etc. This configurations are not working in VSCode.
    "set list
    "set listchars=tab:^\ ,trail:･,nbsp:%,extends:>,precedes:<

    set expandtab
    "set noexpandtab		" Use tab as tab
    set tabstop=4
    set shiftwidth=4    " Number of spaces to use for each step of (auto)indent.  Used for |'cindent'|, |>>|, |<<|, etc.
    set softtabstop=4   " Spaces feel like real tabs

    set helplang=en

    set wildmenu                    " Is this enabled on VSCode?
    set wildmode=longest:full,full  " Is this enabled on VSCode?

    set virtualedit=all

    set mouse=a

    set autoread    " enable auto load the file (depending on your platform)

    " Preferences of each files
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType typescriptreact setlocal ts=2 sts=2 sw=2 expandtab

    set cindent
    filetype plugin indent on
    set cinkeys-=0#
    set indentkeys-=0#
    autocmd FileType * set cindent "some file types override it
else
    " ordinary Neovim
    scriptencoding utf-8
    set encoding=utf-8
    set number
    set incsearch
    set hlsearch
    
    set showmatch      " Already enabled by default?
    set wrapscan       " Already enabled by default?
    set ignorecase     " Ignore case when searching
    set hidden         " Already enabled by default?
    set history=10000  " It should be less or equals to 10,000.
    set whichwrap=h,l

    set ruler          " It should be set combined with "set rulerformat".
                       " Already enabled by default?
    set rulerformat=%-14.(%l,%c%V%)\ %P

    set clipboard=unnamedplus    " user the system clipboard

    " Visualize tags, tails etc
    set list
    set listchars=tab:^\ ,trail:･,nbsp:%,extends:>,precedes:<

    set autoindent     " Already enabled by default?
    set expandtab
    "set noexpandtab		" Use tab as tab
    set tabstop=4
    set shiftwidth=4    " Number of spaces to use for each step of (auto)indent.  Used for |'cindent'|, |>>|, |<<|, etc.
    set softtabstop=4   " Spaces feel like real tabs

    set helplang=en

    set wildmenu
    set wildmode=longest:full,full

    set virtualedit=all

    set mouse=a

    set autoread    " enable auto load the file (depending on your platform)

    set conceallevel=0  " Disable the auto-hide feature in json-vim (https://github.com/spf13/spf13-vim/issues/375#issuecomment-18810973)

    " Preferences of each files
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType typescriptreact setlocal ts=2 sts=2 sw=2 expandtab

    set cindent
    filetype plugin indent on
    set cinkeys-=0#
    set indentkeys-=0#
    autocmd FileType * set cindent "some file types override it

endif



