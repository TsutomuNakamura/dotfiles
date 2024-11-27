" from `:help nvim-from-vim`
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
au InsertLeave * set nopaste
