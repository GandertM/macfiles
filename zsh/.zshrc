# ~~~~~~~~~~~~~~~~~~~~~~ .zshrc ~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~ Globbing ~~~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

# ~~~~~~~~~~~~~~~~~~~~~~ Path Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

path_prepend() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0     # skip if non-existing
  path=("$dir" $path)
}

path_append() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0     # skip if non-existing
  path+=("$dir")
}

path_append  "$HOME/bin"
path_append  "$HOME/projects"

# Remove duplicates in and non-existing from PATH
typeset -aU path       # deduplicate

# Export the PATH variable to make it available to child processes
export PATH

# ~~~~~~~~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set my editor
export EDITOR="fresh"
export VISUAL="codium"

# Set my man pages
export MAN_POSIXLY_CORRECT=1

# ~~~~~~~~~~~~~~~~~~~~~~ Zinit Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
if [[ -r "${ZINIT_HOME}/zinit.zsh" ]]; then
    source "${ZINIT_HOME}/zinit.zsh"
fi

# Add in zsh plugins
if (( ${+functions[zinit]} )); then
    zinit light zsh-users/zsh-syntax-highlighting
    zinit light zsh-users/zsh-completions
    zinit light zsh-users/zsh-autosuggestions
    zinit light Aloxaf/fzf-tab
fi

# Add in snippets (including aliases)
if (( ${+functions[zinit]} )); then
    zinit snippet OMZP::git
    zinit snippet OMZP::sudo
    zinit snippet OMZP::colored-man-pages
    zinit snippet OMZP::command-not-found
fi

# Load completions
autoload -Uz compinit && compinit

if (( ${+functions[zinit]} )); then
    zinit cdreplay -q
fi

# ~~~~~~~~~~~~~~~~~~~~~~ Key Bindings ~~~~~~~~~~~~~~~~~~~~~~~~~~

bindkey -e                            # emacs keybindings

bindkey '^p' history-search-backward  # ctrl-p : search history backward (p = previous)
bindkey '^n' history-search-forward   # ctrl-n : search history forward (n = next)

#bindkey '^[w' kill-region             # alt-w  : kill from the cursor to the mark

bindkey '^[[1;5C' forward-word        # moving between words with CTRL+left
bindkey '^[[1;5D' backward-word       # moving between words with CTRL+right

bindkey '^[u' undo                    # undo with alt+u
bindkey '^[r' redo                    # redo with alt+r

# ~~~~~~~~~~~~~~~~~~~~~~ History Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

# History file location
HISTFILE="$HOME/.zsh_history"

# History file size
SAVEHIST=25000
HISTSIZE=50000

setopt HIST_IGNORE_DUPS         # Prevent consecutive duplicate commands from being stored
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate commands to history
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_SPACE        # Don't save commands that start with a space
setopt HIST_REDUCE_BLANKS       # Remove unnecessary whitespace from history entries
setopt HIST_VERIFY              # Require confirmation before executing history commands
setopt SHARE_HISTORY            # Share history across multiple terminal sessions
setopt INC_APPEND_HISTORY       # Immediately append new commands to history file
setopt EXTENDED_HISTORY         # Save timestamps for each command
setopt APPEND_HISTORY           # Append history instead of overwriting it
setopt HIST_NO_STORE            # Prevent 'history' command itself from being stored

# ~~~~~~~~~~~~~~~~~~~~~~ Conmpletion Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'              # autocompletion with both upper- and lowercase
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"             # autocompletion with colors (only for ls)
zstyle ':completion:*' menu no                                      # disables default zsh completion / see plugin Aloxaf/fzf-tab

if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons --git --group-directories-first "$realpath"'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons --git --group-directories-first "$realpath"'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'  # fzf file browser
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

# ~~~~~~~~~~~~~~~~~~~~~~ Sourcing Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

# Fastfetch
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Shell integrations
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"             # option --zsh only works in 0.48.0 or later (add fzf to PATH)
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"       # see github.com/chhoumann/dotfiles
fi

# Source aliases and functions for every new prompt or after every command
precmd() {
    [[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
    [[ -f "$HOME/.zsh_functions" ]] && source "$HOME/.zsh_functions"
}

# ~~~~~~~~~~~~~~~~~~~~~~ End Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~ Thanks to ~~~~~~~~~~~~~~~~~~~~~~~~~~
# Youtube 'Dreams of Autonomy' for guidance
# github.com/chhoumann/dotfiles for examples
# ~~~~~~~~~~~~~~~~~~~~~~ END ~~~~~~~~~~~~~~~~~~~~~~~~~~