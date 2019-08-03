#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set aliases for commonly used command.
if [[ "${OSTYPE}" =~ freebsd.* ]] || [[ "${OSTYPE}" =~ darwin.* ]]; then
    alias ls="ls -G -w"
else
    alias ls='ls --color=auto'
fi

PROMPT_COMMAND=__prompt_command

[[ $(id -u) -eq 0 ]] && prompt_prefix="#" || prompt_prefix="$"

function __prompt_command() {
    local EXIT="$?"
    if [[ "$EXIT" -ne 0 ]]; then
        printf "\e[38;05;242m%*s\e[0m\r" "$(tput cols)" ".$EXIT "
        if [[ "$UID" -eq 0 ]]; then
            PS1="@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ "
        else
            PS1="\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ "
        fi
    else
        if [[ "$UID" -eq 0 ]]; then
            PS1="@\h \W\[\e[38;05;45m\]$prompt_prefix\[\e[0m\]>_ "
        else
            PS1="\u@\h \W\[\e[38;05;45m\]$prompt_prefix\[\e[0m\]>_ "
        fi
    fi
}
PS2="\e[38;05;242m>_\e[0m "

# Set environment
if (command -v nvim > /dev/null 2>&1); then
    export VISUAL=nvim
    export EDITOR=nvim
    # Type `\vim` or `command vim` if you want to use original one.
    alias vim="nvim"
    alias vi="nvim"
    alias vimdiff="nvim -d"
else
    export VISUAL=vim
    export EDITOR=vim
fi

export PATH="${PATH}:${HOME}/bin"

# Prepare golang environment
if [[ -d "${HOME}/go/bin" ]]; then
    export PATH="${PATH}:${HOME}/go/bin"
fi

# Set GPG_PATH
export GPG_PATH=$(tty)

# Load user specific environment
[[ -d "${HOME}/.bash_modules/" ]] && while read f; do . "$f"; done < <(find "${HOME}/.bash_modules/" -type f)
[[ -f ~/.user_specificrc ]] && . ~/.user_specificrc || true


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
