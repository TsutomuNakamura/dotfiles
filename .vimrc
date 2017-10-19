scriptencoding utf-8
set encoding=utf-8

set number			" show line number
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

" enable auto load the file (depending on your platform)
set autoread

" Change leader for vim plugins
let mapleader = ";"

if &diff                             " only for diff mode/vimdiff
  set diffopt=filler,context:1000000 " filler is default and inserts empty lines for sync
endif

" TODO: Test settingf from here
let g:airline_powerline_fonts = 1
let g:airline_theme = 'simple'
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1
" let g:tmuxline_theme = 'powerline'

" Mapping for ctrlp
let g:ctrlp_map = '<c-l><c-p>'
let g:ctrlp_cmd = 'CtrlP'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:tmuxline_preset = {
      \'c'    : '#H',
      \'win'  : '#I.#W',
      \'cwin' : '#I.#W',
      \'z'    : '%a %m/%d/%Y %R'}

" Paste from clipboard/yanked text in command line mode
cnoremap <C-v><C-v> <C-r>+
inoremap <C-v><C-v> <C-r>+
cnoremap <C-v>p <C-r><C-o>"

" set color scheme
syntax enable
set t_Co=256
""""colorscheme molokai
let g:molokai_original=1
" TODO
colorscheme molokai

" vim-pathogen. Auto load plugins
execute pathogen#infect()

let NERDSpaceDelims = 1

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

" ----------------------------------------------------------------------------------
" Visible zenkaku space
" ----------------------------------------------------------------------------------
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

" ----------------------------------------------------------------------------------
" Set pasting tric. Thanks for nice tric.
" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
" ----------------------------------------------------------------------------------
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

" open NERDTree
nnoremap <silent> tr  :<C-u>NERDTree<CR>

" ----------------------------------------------------------------------------------
" tab page settings
" 
" reference
" http://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
" ----------------------------------------------------------------------------------
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

" 個別のタブの表示設定をします
function! GuiTabLabel()
  " タブで表示する文字列の初期化をします
  let l:label = ''

  " タブに含まれるバッファ(ウィンドウ)についての情報をとっておきます。
  let l:bufnrlist = tabpagebuflist(v:lnum)

  " 表示文字列にバッファ名を追加します
  " パスを全部表示させると長いのでファイル名だけを使います 詳しくは help fnamemodify()
  let l:bufname = fnamemodify(bufname(l:bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
  " バッファ名がなければ No title としておきます。ここではマルチバイト文字を使わないほうが無難です
  let l:label .= l:bufname == '' ? 'No title' : l:bufname

  " タブ内にウィンドウが複数あるときにはその数を追加します(デフォルトで一応あるので)
  let l:wincount = tabpagewinnr(v:lnum, '$')
  if l:wincount > 1
    let l:label .= '[' . l:wincount . ']'
  endif

  " このタブページに変更のあるバッファがるときには '[+]' を追加します(デフォルトで一応あるので)
  for bufnr in l:bufnrlist
    if getbufvar(bufnr, "&modified")
      let l:label .= '[+]'
      break
    endif
  endfor

  " 表示文字列を返します
  return l:label
endfunction

" guitablabel に上の関数を設定します
" その表示の前に %N というところでタブ番号を表示させています
set guitablabel=%N:\ %{GuiTabLabel()}

if !filereadable(expand("~/.vimrc_do_not_use_ambiwidth"))
  source ~/.vim/myconf/ambiwidth.conf
endif

"" nerdcommenter https://github.com/scrooloose/nerdcommenter
source ~/.vim/myconf/nerdcommenter.conf

