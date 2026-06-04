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
 
HISTSIZE=25000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase

# If this is set, zsh sessions will append their history list to the history file, rather than replace it. 
setopt append_history

# This option both imports new commands from the history file, and also causes your typed commands to be appended to the history file.
setopt share_history

# Remove command lines from the history list when the first character on the line is a space, or when one of the expanded aliases contains a leading space. 
setopt hist_ignore_space

# If a new command line being added to the history list duplicates an older one, the older command is removed from the list (even if it is not the previous event).
setopt hist_ignore_all_dups

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt hist_save_no_dups

# Do not enter command lines into the history list if they are duplicates of the previous event.
setopt hist_ignore_dups

# When searching for history entries in the line editor, do not display duplicates of a line previously found, even if the duplicates are not contiguous.
setopt hist_find_no_dups

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