" from `:help nvim-from-vim`
if exists('g:vscode')
    source ~/.nvimrc_vscode
else
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
    au InsertLeave * set nopaste
endif

