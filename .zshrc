autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
# End of lines configured by zsh-newuser-install

# Style and color of prompt
# http://unix.stackexchange.com/questions/25319/256-colour-prompt-in-zsh
# https://web.archive.org/web/20120905043337/http://lucentbeing.com/blog/that-256-color-thing
if [ $(id -u) -eq 0 ]; then
    PROMPT='%{[22m%}@%{[0m%}%m %c%(?.%{[22;38;05;45m%}#%{[0m%}.%{[22;38;05;197m%}$%{[0m%}) '
else
    PROMPT='%n@%m %c%(?.%{[22;38;05;45m%}$%{[0m%}.%{[22;38;05;197m%}$%{[0m%}) '
fi
RPROMPT='%(?..%{[22;38;05;242m%}.%?%{[0m%})'
PROMPT2="%{[22;38;05;242m%}>%{[0m%} "

alias ls='ls --color=auto'

