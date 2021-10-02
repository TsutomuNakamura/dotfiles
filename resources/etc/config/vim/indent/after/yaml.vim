" - Stop vim from messing up indentation on comments ---------------------------------------------------------
" https://unix.stackexchange.com/questions/106526/stop-vim-from-messing-up-my-indentation-on-comments
set nosmartindent
set cindent
filetype plugin indent on
set cinkeys-=0#
set indentkeys-=0#
autocmd FileType * set cindent
