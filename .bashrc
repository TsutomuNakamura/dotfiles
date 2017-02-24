#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PROMPT_COMMAND=__prompt_command

[[ $(id -u) -eq 0 ]] && prompt_prefix="#" || prompt_prefix="$"

function __prompt_command() {
    local EXIT="$?"
    if [[ "$EXIT" -ne 0 ]]; then
        #PS1="\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ "
        # PS1=$(printf "\[\e[38;05;242m\]%*s\[\e[0m\]\r%s " "$(tput cols)" ".$EXIT " "\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ ")
        #PS1=$(printf "\[\e[38;05;242m\]%*s\[\e[0m\]\r%s" "$(tput cols)" ".$EXIT " "\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ ")
        #PS1=$(printf "\[\e[38;05;242m\]%*s\[\e[0m\]\r%s\[\e[38;05;197m\]%s\[\e[0m\]%s" "$(tput cols)" ".$EXIT " "\u@\h \W" "$prompt_prefix" ">_")
        ## PS1=$(printf "%*s\r%s" "$(tput cols)" ".$EXIT " "\u@\h \W$prompt_prefix>_")
        ## PS1=$(printf "%*s\r%s" "$(($(tput cols)+${compensate}))" ".$EXIT " "\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ ")

        # printf "\[\e[38;05;242m\]%*s\[\e[0m\]\r" "$(tput cols)" "$EXIT "
        printf "\e[38;05;242m%*s\e[0m\r" "$(tput cols)" ".$EXIT "
        PS1="\u@\h \W\[\e[38;05;197m\]$prompt_prefix\[\e[0m\]>_ "
    else
        #PS1="\u@\h \W$prompt_prefix\[\e[38;05;45m\]>_\[\e[0m\] "
        PS1="\u@\h \W\[\e[38;05;45m\]$prompt_prefix\[\e[0m\]>_ "
    fi
}
PS2="\e[38;05;242m>_\e[0m "

export EDITOR=vim
export PATH="${PATH}:${HOME}/bin"

