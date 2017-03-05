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
        PS1="\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ "
    else
        PS1="\u@\h \W\[\e[38;05;45m\]$prompt_prefix\[\e[0m\]>_ "
    fi
}
PS2="\e[38;05;242m>_\e[0m "

export PATH="${PATH}:${HOME}/bin"

