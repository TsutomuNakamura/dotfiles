# Set zsh completion.
autoload -Uz compinit
compinit

# Use cache for completion
zstyle ':completion::complete:*' use-cache 1
# Print message when no matches were found.
zstyle ':completion:*:warnings' format 'No matches for %d'
# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
# End of lines configured by zsh-newuser-install

# Set prompt style.
# This specifications makes the prompt simply and reports exit status code of the last command to you with color in left side prompt and a number in right side prompt.
#   referenc)
#   http://unix.stackexchange.com/questions/25319/256-colour-prompt-in-zsh
#   https://web.archive.org/web/20120905043337/http://lucentbeing.com/blog/that-256-color-thing
if [ $(id -u) -eq 0 ]; then
    PROMPT='%{[22m%}@%{[0m%}%m %c%(?.%{[22;38;05;45m%}#%{[0m%}.%{[22;38;05;197m%}#%{[0m%}) '
else
    PROMPT='%n@%m %c%(?.%{[22;38;05;45m%}$%{[0m%}.%{[22;38;05;197m%}$%{[0m%}) '
fi
RPROMPT='%(?..%{[22;38;05;242m%}.%?%{[0m%})'
PROMPT2="%{[22;38;05;242m%}>%{[0m%} "

# Set aliases for commonly used command.
if [[ "${OSTYPE}" =~ freebsd.* ]] || [[ "${OSTYPE}" =~ darwin.* ]]; then
    alias ls="ls -G -w"
    export CLICOLOR=1
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
else
    alias ls='ls --color=auto'

    # Set ls colors to be able to identify the filetype intuitively for user.
    if [[ -z "$LS_COLORS" ]]; then
        export LS_COLORS='rs=0:di=38;5;33:ln=38;5;51:mh=00:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=01;05;37;41:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;40:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.m4a=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.oga=38;5;45:*.opus=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'
    fi
fi

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

export EDITOR=vim

if (command -v most > /dev/null 2>&1); then
    export PAGER=most
elif (command -v less > /dev/null 2>&1); then
    export PAGER=less
else
    export PAGER=more
fi


# Set terminal color variation to 256 for tmux and vim etc.
##export TERM=xterm-256color

# Set the keybind like emacs (and bash too)
bindkey -e

# Set colors when completion also.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Perform the cd command to that directory if only the directory was specified.
setopt AUTO_CD
# Command that duplicates with last one command will not be added in the history.
setopt HIST_IGNORE_DUPS
# Reduce extra spaces in history.
setopt HIST_REDUCE_BLANKS
# Remove trailing spaces after completion if needed.
setopt AUTO_PARAM_KEYS
# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD
# Don't push multiple copies of the same directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS
# Disable complement
setopt NONOMATCH

# Append bin just below user's home directory to PATH to execute user specific command.
export PATH="${HOME}/bin:${PATH}:${HOME}/.local/bin"

# Prepare golang environment
if [[ -d "${HOME}/go/bin" ]]; then
    export PATH="${PATH}:${HOME}/go/bin"
fi

# Set GPG_PATH
export GPG_PATH=$(tty)

# Load user specific environment
[[ -f ~/.user_specificrc ]] && . ~/.user_specificrc || true

alias -s {txt}='vim'
alias -s pdf='background open-with-google-chrome'
setopt interactivecomments

if [ -f ~/.zsh/antigen/antigen.zsh ]; then
    source ~/.zsh/antigen/antigen.zsh

    #antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen apply

    # Settings for zsh-autosuggestions
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240,underline"
    bindkey '^ ' autosuggest-accept     # Ctrl + Space: Accept auto suggestion
    bindkey '^l' autosuggest-accept     # Ctrl + l: Accept auto suggestion

    # Settings for zsh-syntax-highlight
    # See documantation: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
    #typeset -A ZSH_HIGHLIGHT_HIGHLIGHTERS
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
    #ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=197,underline"
    #ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=255,underline"
    #ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=227"
    ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=45"
    #ZSH_HIGHLIGHT_STYLES[alias]="fg=45"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=45,bold"
    ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=45,standout"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=45,bold"              # pwd, echo, shift zstyle alias etc...
    ZSH_HIGHLIGHT_STYLES[function]="fg=45,underline"
    ZSH_HIGHLIGHT_STYLES[command]="fg=45,bold"
    ZSH_HIGHLIGHT_STYLES[precommand]="fg=45,underline"      # noglob builtin command etc...
    ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=255,bold"
    # * hashed command example
    #     hash -d d=~/.dotfiles
    #   Then you can change directory to ~/.dotfiles with `cd ~d`
    #   "~d" will be highlighted by ZSH_HIGHLIGHT_STYLES[hashed-command]
    ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=45,standout"
    #ZSH_HIGHLIGHT_STYLES[path]="fg=255,underline"
    #ZSH_HIGHLIGHT_STYLES[path]="fg=255"

    # Path separators in filenames(/). If unset "path" is used(default)
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]="bold"
    ##ZSH_HIGHLIGHT_STYLES[path_prefix]="bold"
    ZSH_HIGHLIGHT_STYLES[globbing]="bold"
    ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=45,standout"
    ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=255"
    #ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]="fg=255"
    #ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]="fg=255"
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=197"
    #ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]="fg=197"
    #ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]="fg=197"
    #ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=255"
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=197"
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=226"
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=226"
    #ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=197,underline"
    #ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=197,underline"
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=197,bold"

    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=255"
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="underline"

    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=255"
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="underline"

    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=255,bold"
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="underline"

    #ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=226"

    # parameter expansion inside double quotes ($foo inside "")
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=46"
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=45"
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=226"

    ZSH_HIGHLIGHT_STYLES[assign]="fg=45,underline"
    ZSH_HIGHLIGHT_STYLES[redirection]="fg=226,bold"
    ZSH_HIGHLIGHT_STYLES[comment]="fg=243"
    ZSH_HIGHLIGHT_STYLES[named-fd]="bold"

    ZSH_HIGHLIGHT_STYLES[arg0]="fg=243"
    #ZSH_HIGHLIGHT_STYLES[default]="fg=255"

    # bracket-level
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=45"
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=197'
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=47,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=226,bold"

    #typeset -A ZSH_HIGHLIGHT_PATTERNS
    #ZSH_HIGHLIGHT_PATTERNS+=('rm -rf /*/' 'fg=197,standout')

    #typeset -A ZSH_HIGHLIGHT_REGEXP
    #ZSH_HIGHLIGHT_REGEXP+=('\brm \-rf /.*\b' 'fg=197,standout')
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

true
