if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # If you're using macOS, you'll want this enabled
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit load zsh-users/zsh-syntax-highlighting
zinit load zsh-users/zsh-completions
zinit load zsh-users/zsh-autosuggestions
zinit load Aloxaf/fzf-tab
# zinit ice depth=1
# zinit load jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# bindkey -v

# Aliases
alias tt="taskwarrior-tui"
alias kb="kubectl"
alias kns="kubens"
alias kct="kubectx"
alias k9="k9s"
alias c="code"
alias vim="nvim"
alias v="nvim"
alias f="fzf"
alias fo="cd ~/src && fzf --preview 'bat --style=numbers --color=always {}' | xargs -n 1 nvim"
alias fcd='cd ~/src && cd "$(find . -type d \( -path '\''*/.git'\'' -o -path '\''*/node_modules'\'' \) -prune -o -type d -print | fzf)"'
alias lgit="lazygit"
alias ldocker="lazydocker"
alias clear="clear && printf '\e[3J'"
alias ls="ls --color"
alias tree='tree -a -I ".git|node_modules"'
alias rip="~/.dotfiles/rip.sh"
alias air="~/go/bin/air"
alias ll="ls -lah"
alias ta="tmux attach"
alias t="tmux"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/bison/bin:$PATH"
export PATH="/Users/endalk200/.local/bin:$PATH"
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

source ~/src/projects/bethel/config.sh
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="~/.chef/gem/ruby/3.0.0/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

eval "$(pyenv virtualenv-init -)"
. "$HOME/.cargo/env"

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# source ~/.config/tsm/tsm.sh

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

# History
HISTSIZE=100000 # 1,000,000 :- the number of commands to load into memory
HISTFILE=~/.zsh_history
SAVEHIST=100000 # The number of commands saved into HISTFILE
HISTDUP=erase # Remove older duplicate commands from the history list, keeping only the most recent occurrence.

export HISTTIMEFORMAT="[%F %T] " # 

setopt INC_APPEND_HISTORY # Commands should be added to history file immediately
setopt EXTENDED_HISTORY # Record the commands with the actual timestamp
setopt HIST_IGNORE_ALL_DUPS # Extension HIST_FIND_NO_DUPS. Don't save duplicate commands
setopt HIST_EXPIRE_DUPS_FIRST # delete duplicates first when HISTFILE size exceeds HISTSIZE

# setopt APPENDHISTORY # Append to history file don't override it
setopt SHAREHISTORY # Share command history between all running zsh sessions
setopt HIST_IGNORE_SPACE # Ignore commands starting with space 

