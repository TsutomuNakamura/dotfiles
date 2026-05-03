# ~/.config/codesh/.bashrc
# Minimal bash config for VS Code terminals.
# Optimised for AI (Copilot) use: no colors, no pagers, no interactive plugins.

# ── Output ────────────────────────────────────────────────────────────────────
export NO_COLOR=1
unset LS_COLORS

# ── Pagers ────────────────────────────────────────────────────────────────────
export PAGER=cat
export GIT_PAGER=cat
export MANPAGER=cat

# ── Prompt ────────────────────────────────────────────────────────────────────
PS1='$ '

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.bash_history
HISTSIZE=100000
HISTCONTROL=ignoredups:erasedups

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="${HOME}/bin:${PATH}:${HOME}/.local/bin"
[[ -d "${HOME}/go/bin" ]] && export PATH="${PATH}:${HOME}/go/bin"

# ── Editor ────────────────────────────────────────────────────────────────────
if command -v nvim > /dev/null 2>&1; then
    export VISUAL=nvim
    export EDITOR=nvim
else
    export VISUAL=vim
    export EDITOR=vim
fi

# ── Java / sdkman ─────────────────────────────────────────────────────────────
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk

export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

# ── Node / nvm ────────────────────────────────────────────────────────────────
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

# ── User-specific overrides ───────────────────────────────────────────────────
[[ -f ~/.user_specificrc ]] && source ~/.user_specificrc || true

# ── VS Code shell integration ─────────────────────────────────────────────────
[[ "$TERM_PROGRAM" == "vscode" ]] && source "$(code --locate-shell-integration-path bash)"
