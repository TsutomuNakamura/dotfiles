" - General specifications -----------------------------------------------------------------------------------
scriptencoding utf-8
set encoding=utf-8

set number			" show line number
" set relativenumber	" show line number relatively

set incsearch		" Enable incremental
set hlsearch		" Enable search highlight
"set nowrap			" Disable word wrap
set showmatch		" Enable highlight corresponding brackets
set wrapscan		" Searches wrap around the end of the file
set ignorecase		" Ignore case in search patterns
set hidden			" When on a buffer becomes hidden when it is |abandon|ed.
					" If the buffer is still displayed in another window, it does not become hidden, of course.
set history=1024	" A history of ':' commands, and a history of previous search patterns are remembered.

set whichwrap=h,l	" Prevent Allow specified keys that move the cursor left/right
					" to move to the previous/next line when the cursor is on the first/last character in the line.

set ruler			" When enabled, the ruler is displayed on the right side of the status line at the bottom of the window.
					" http://choorucode.com/2010/11/28/vim-ruler-and-default-ruler-format/
"set rulerformat=%-14.(%l,%c%V%)\ %P

set clipboard=unnamedplus    " user the system clipboard

" # Visualization tags, tails etc
set list
set listchars=tab:^\ ,trail:･,nbsp:%,extends:>,precedes:<

set autoindent		" Enable auto indent
set expandtab		" Use tab as space
"set noexpandtab		" Use tab as tab
set tabstop=4
set shiftwidth=4	" Number of spaces to use for each step of (auto)indent.  Used for |'cindent'|, |>>|, |<<|, etc.
set softtabstop=4	" Spaces feel like real tabs

set helplang=en

" enable ex utility (:<tab>)
set wildmenu
set wildmode=longest:full,full

set virtualedit=block

" 
set mouse=a

" enable auto load the file (depending on your platform)
set autoread

" Disable the auto-hide feature in json-vim (https://github.com/spf13/spf13-vim/issues/375#issuecomment-18810973)
set conceallevel=0

" - Preferences of yaml file ---------------------------------------------------------------------------------
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescriptreact setlocal ts=2 sts=2 sw=2 expandtab

" Change leader for vim plugins from '\'
let mapleader = ";"
" - vimdiff specifications -----------------------------------------------------------------------------------
if &diff                             " only for diff mode/vimdiff
  set diffopt=filler,context:1000000 " filler is default and inserts empty lines for sync
endif

autocmd Filetype html setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" - Additional keymaps ---------------------------------------------------------------------------------------
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


" - Configuration for vim-plug -------------------------------------------------------------------------------
" To install plugins run a command linke below from CLI interface.
" ~$ vim +PlugInstall +"sleep 1000m" +qall
call plug#begin('~/.vim/plugged')
" Prefix 'https://github.com/' is abbreviated.
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-scripts/sudo.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'Valloric/YouCompleteMe'
Plug 'posva/vim-vue'
Plug 'airblade/vim-gitgutter'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/indentLine'
Plug 'terryma/vim-multiple-cursors'
Plug 'pangloss/vim-javascript'
"Plug 'maxmellon/vim-jsx-pretty'

Plug 'mxw/vim-jsx'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" - markdown-preview.nvim --------------------------------------------------------
" If you don't have nodejs and yarn
" use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
" see: https://github.com/iamcco/markdown-preview.nvim/issues/50
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" If you have nodejs and yarn
""Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" To prevent the issue: https://github.com/Yggdroot/indentLine/issues/140
" https://vi.stackexchange.com/questions/7258/how-do-i-prevent-vim-from-hiding-symbols-in-markdown-and-json
Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0
let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2

" Color schemes of molokai ----
""Plug 'tomasr/molokai'

" Tmux line of vim ----
""Plug 'edkolev/tmuxline.vim'

" Required, plugins available after.
call plug#end()

" - Settings of vim YouCompleteMe -----------------------------------------------------------------------------
let g:ycm_global_ycm_extra_conf = '${HOME}/.ycm_extra_conf.py'
let g:ycm_auto_trigger = 1
let g:ycm_min_num_of_chars_for_completion = 3
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
set splitbelow

" - Settings of vim-airline ----------------------------------------------------------------------------------
let g:airline_powerline_fonts = 1
let g:airline_theme = 'simple'
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1
" let g:tmuxline_theme = 'powerline'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" - Mappings for ctrlp ---------------------------------------------------------------------------------------
let g:ctrlp_map = '<c-l><c-p>'
let g:ctrlp_cmd = 'CtrlP'

" - Mappings for ctrlp ---------------------------------------------------------------------------------------
"" This is a setting of 'edkolev/tmuxline.vim'.
"let g:tmuxline_preset = {
"      \'c'    : '#H',
"      \'win'  : '#I.#W',
"      \'cwin' : '#I.#W',
"      \'z'    : '%a %m/%d/%Y %R'}

" - Setting for Yggdroot/indentLine --------------------------------------------------------------------------
let g:indentLine_color_term = 234
" let g:indentLine_char_list = ['┊']

" - Settings of clip board -----------------------------------------------------------------------------------
" Paste from clipboard/yanked text in command line mode
cnoremap <C-v><C-v> <C-r>+
inoremap <C-v><C-v> <C-r>+
cnoremap <C-v>p <C-r><C-o>"

" - Settings of vim gitgutter -----------------------------------------------------------------------------
set updatetime=350

" - Settings for fzf -----------------------------------------------------------------------------
nnoremap <silent> ff  :<C-u>Files<CR>
nnoremap <silent> gf  :<C-u>GFiles<CR>
let g:fzf_buffers_jump = 1

" - Settings of color scheme ---------------------------------------------------------------------------------
" set color scheme
syntax enable
set t_Co=256
try
    colorscheme molokai
catch /^Vim\%((\a\+)\)\=:E185/
    " deal with it
endtry
let g:molokai_original=1

" - Visible zenkaku space ------------------------------------------------------------------------------------
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
  augroup END
  call ZenkakuSpace()
endif


" - Pasting settings -----------------------------------------------------------------------------------------
" Set pasting tric. Thanks for nice tric.
" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

" - Markdown Preview for (Neo)vim -----------------------------------------------------------
" https://github.com/iamcco/markdown-preview.nvim
" * Command
" ':MarkdownPreview': Start the Markdown preview
" ':MarkdownPreviewStop': Stop the Markdown preview


" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = ''

" specify browser to open preview page
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 0

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }

" use a custom markdown style must be absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" use a custom port to start server or random for empty
let g:mkdp_port = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" - NERDTree settings ----------------------------------------------------------------------------------------
" open NERDTree
nnoremap <silent> tr  :<C-u>NERDTree<CR>

" - Settings for multi cursor (terryma/vim-multiple-cursors) -------------------------------------------------
let g:multi_cursor_use_default_mapping=0

" Default mapping
"let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_start_word_key      = '<C-m>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-m>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
"let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_next_key            = '<C-m>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" - Visuals of tabs ------------------------------------------------------------------------------------------
function! GuiTabLabel()
  " Initialize a string of tab.
  let l:label = ''
  " Store information of the tab temporary.
  let l:bufnrlist = tabpagebuflist(v:lnum)

  " Add the information(file name).
  " If it show entire path of the file, it's become too long to show.
  " So to show the file name only. For more information show `help fnamemodify()`.
  let l:bufname = fnamemodify(bufname(l:bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
  " If no file name, set text 'No title'.
  " It's safe not to use multi byte characters.
  let l:label .= l:bufname == '' ? 'No title' : l:bufname

  " If there are multi windows in tab, add number of them.
  let l:wincount = tabpagewinnr(v:lnum, '$')
  if l:wincount > 1
    let l:label .= '[' . l:wincount . ']'
  endif

  " Add a string '[+]' if there are changed buffers in its page.
  for bufnr in l:bufnrlist
    if getbufvar(bufnr, "&modified")
      let l:label .= '[+]'
      break
    endif
  endfor

  " Return string to display
  return l:label
endfunction

" Set a function GuiTabLabel() in the variable 'guitablabel'.
" '%N' express a sequence number of its tab.
set guitablabel=%N:\ %{GuiTabLabel()}

if !filereadable(expand("~/.vimrc_do_not_use_ambiwidth")) && filereadable(expand("~/.vim/myconf/ambiwidth.conf")) && !filereadable("/.dockerenv") && !has("macunix")
  source ~/.vim/myconf/ambiwidth.conf
endif

" nerdcommenter https://github.com/scrooloose/nerdcommenter
if filereadable(expand("~/.vim/myconf/nerdcommenter.conf"))
  source ~/.vim/myconf/nerdcommenter.conf
endif
