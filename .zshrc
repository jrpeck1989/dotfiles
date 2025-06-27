# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
#!/bin/zsh# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$PATH:$HOME"
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/postgresql@16/bin:$PATH"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# plugins=(git zsh-syntax-highlighting)
export FUNCNEST=100

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# -----------------------------------------------------------------------------
#  MISC
# -----------------------------------------------------------------------------

# 1Password CLI stuff
eval "$(op completion zsh)"; compdef _op op

# -----------------------------------------------------------------------------
#  DOCKER
# -----------------------------------------------------------------------------

# Removes all closed / exited Docker Containers
function docker-rmc() {
  docker ps -a -q | while read id; do docker rm $id; done
}

# Removes all partial and dangling docker images (note: run docker-rm first to remove links)
function docker-rmi() {
  docker images -f "dangling=true" -q | while read id; do docker rmi $id; done
}

export VAULT_ADDR={{VAULT_ADDR}}
__vault_token_path=~/.vault-token
__tf_secrets_dir=~/.tf_secrets

function prod-vault-login() {
  export VAULT_ADDR=https://vault.snplow.net

  local vault_token_found="false"

  if [ -f "${__vault_token_path}" ]; then
    local vault_token
    local token_lookup_retval

    vault_token=$(cat "${__vault_token_path}")

    vault token lookup "${vault_token}" > /dev/null 2>&1
    # shellcheck disable=SC2116
    token_lookup_retval="$(echo $?)"

    if [ "${token_lookup_retval}" -eq "0" ]; then
      vault_token_found="true"
    fi
  fi

  if [ "${vault_token_found}" == "false" ]; then
    read -srp 'Enter GitHub token for Vault login: ' vault_github_token
    echo
    vault login -method=github token="${vault_github_token}" > /dev/null 2>&1
  fi

  # Ensure local token always expires after 12 hours
  vault token renew -increment=12h "$(cat "${__vault_token_path}")" > /dev/null 2>&1

  echo "Vault login complete."
}

function prod-grafana-creds() {
  local grafana_auth_path="${__tf_secrets_dir}/grafana_auth_prod.txt"
  local grafana_auth
  mkdir -p "${__tf_secrets_dir}"

  if [ -f "${grafana_auth_path}" ]; then
    grafana_auth="$(cat "${grafana_auth_path}")"
  else
    read -rp 'Enter Grafana email address: ' grafana_email_address
    read -srp 'Enter Grafana password: ' grafana_password
    echo

    grafana_auth="${grafana_email_address}:${grafana_password}"
    echo "${grafana_auth}" > "${grafana_auth_path}"
  fi

export GRAFANA_URL="{{GRAFANA_URL}}"
  export GRAFANA_AUTH="${grafana_auth}"

  echo "Prod Grafana credentials set."
}

function prod-github-token() {
  local github_token_path="${__tf_secrets_dir}/github_token_prod.txt"
  local github_token
  mkdir -p "${__tf_secrets_dir}"

  if [ -f "${github_token_path}" ]; then
    github_token="$(cat "${github_token_path}")"
  else
    read -srp 'Enter GitHub token: ' github_token
    echo
    echo "${github_token}" > "${github_token_path}"
  fi

  export GITHUB_TOKEN="${github_token}"

  echo "Prod GitHub credentials set."
}

export CONSUL_HTTP_ADDR={{CONSUL_HTTP_ADDR}};
export CONSUL_SCHEME=https;
export CONSUL_HTTP_SSL=true;

function get-prod-consul-token() {
  vault read consul/creds/services | grep token | rev | cut -d " " -f1 | rev
}

export GH_TOKEN="{{GH_TOKEN}}"
export GH_EDITOR="cursor -w"

function vault_auth {
    echo "——————————————————————————— vault ————————————————————————————————————"
    vault login -method=github token="${GH_TOKEN}"

    CONSUL_HTTP_TOKEN=$(vault read consul/creds/services | grep token | rev | cut -d " " -f1 | rev)
    NOMAD_TOKEN=$(vault read nomad/creds/nomad-viewer | grep secret_id | rev | cut -d " " -f1 | rev)

    echo "——————————————————————————— consul ————————————————————————————————————"
    export CONSUL_HTTP_TOKEN
    echo "CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}"
}

function run_micro() {
local WATCHED_DIR="$HOME/Documents/snowplow-micro/example"
    local IMAGE_NAME="snowplow/snowplow-micro:latest"
    local CONTAINER_NAME="micro"
    local WATCHER_PID

    # Cleanup function to be called on exit
    function cleanup() {
        echo -e "\nStopping processes..."
        # Kill the file watcher if it's running
        if [[ -n "$WATCHER_PID" ]]; then
            kill "$WATCHER_PID" 2>/dev/null
        fi
        # Stop the docker container
        docker stop "$CONTAINER_NAME" &>/dev/null || true
        echo "Cleanup complete. Exiting."
    }

    # Set up trap to call cleanup on script exit (Ctrl+C)
    trap cleanup INT TERM EXIT

    # Start the file watcher in the background.
    # When it detects a change, it just stops the container,
    # which will cause the 'docker logs' command to exit and the main loop to restart.
    (fswatch -o "$WATCHED_DIR" | while read -r; do
        echo -e "\n--- Change detected, restarting container ---"
        docker stop "$CONTAINER_NAME" >/dev/null
    done) &
    WATCHER_PID=$!

    # Main loop
    while true; do
        echo "Starting container '$CONTAINER_NAME'..."
        docker run --rm -d --name "$CONTAINER_NAME" -p 9090:9090 \
            --mount type=bind,source="$WATCHED_DIR/enrichments",destination=/enrichments \
            --mount type=bind,source="$WATCHED_DIR",destination=/config \
            "$IMAGE_NAME" >/dev/null

        # Check if the container started successfully
        if ! docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
            echo "Error: Container failed to start."
            # Wait before trying again
            sleep 5
            continue
        fi

        echo "Tailing logs... (Press Ctrl+C to exit)"
        # This command will block until the container is stopped
        docker logs -f "$CONTAINER_NAME"
        
        # Add a small delay to prevent rapid looping if 'docker logs' exits unexpectedly
        sleep 1
    done
}

function run_micro_dev() {
    # 1. Dependency checks
    if ! command -v fswatch &> /dev/null; then
        echo "Error: fswatch is not installed. Please install it to continue." >&2
        echo "On macOS, you can run: brew install fswatch" >&2
        return 1
    fi

    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Please install it to continue." >&2
        return 1
    fi

    # 2. Configuration and path checks
    local watched_dir="./example"
    if [[ ! -d "$watched_dir" ]]; then
        echo "Error: Directory to watch ('$watched_dir') not found." >&2
        echo "Please make sure you are in the root of the 'snowplow-micro' project directory." >&2
        return 1
    fi
    local image_name="snowplow/snowplow-micro:latest"
    local container_name="snowplow-micro-dev"
    local watcher_pid

    # 3. Cleanup function for graceful shutdown
    function cleanup() {
        echo -e "\n\nSIGINT received, shutting down..."
        
        # Disable the trap to prevent re-entrant calls
        trap - INT TERM

        # Stop the file watcher
        if [[ -n "$watcher_pid" ]] && ps -p "$watcher_pid" > /dev/null; then
            echo "Stopping file watcher (PID: $watcher_pid)..."
            kill "$watcher_pid" 2>/dev/null
        fi

        # Stop and remove the Docker container
        echo "Stopping and removing Docker container '$container_name'..."
        if docker ps -a -q --filter "name=$container_name" | grep -q .; then
            docker rm -f "$container_name" > /dev/null
        fi
        
        echo "Shutdown complete. Goodbye!"
        # Exit the script with a standard code for interruption
        exit 130
    }

    trap cleanup INT TERM

    # 4. Initial cleanup of any orphaned container
    echo "Checking for and removing any old '$container_name' containers..."
    if docker ps -a -q --filter "name=$container_name" | grep -q .; then
        docker rm -f "$container_name" > /dev/null
    fi

    # 5. Start file watcher
    echo "Watching for file changes in '$watched_dir'..."
    # -o batches events, -r is for recursive watching.
    fswatch -or "$watched_dir" | while read -r event_path; do
        echo "-> File change detected: $event_path"
        echo "   Restarting Snowplow Micro container..."
        if docker ps -q --filter "name=$container_name" | grep -q .; then
            docker stop "$container_name" > /dev/null
        fi
    done &
    watcher_pid=$!

    # 6. Main loop to run and monitor Docker container
    while true; do
        echo "Starting Snowplow Micro container '$container_name'..."
        docker run \
            --rm \
            -d \
            --name "$container_name" \
            -p 9090:9090 \
            --mount type=bind,source="$(pwd)/$watched_dir/enrichments",destination=/enrichments \
            --mount type=bind,source="$(pwd)/$watched_dir",destination=/config \
            "$image_name" > /dev/null

        if ! docker ps -q --filter "name=$container_name" | grep -q .; then
            echo "Error: Container '$container_name' failed to start." >&2
            echo "Will retry in 5 seconds..."
            sleep 5
            continue
        fi

        echo "Container started. Tailing logs... (Ctrl+C to stop)"
        
        # Block and stream logs. When container is stopped, this command will exit.
        docker logs -f "$container_name"

        # If the loop continues (e.g., container was stopped by fswatch), wait a moment.
        # This also prevents fast-spinning loops if the container fails instantly.
        sleep 0.5
    done
}

function run-server() {
  trap 'cleanup' INT

  function cleanup() {
    echo "Shutting down server and freeing up port 8888..."
    kill $!
    wait $! 2>/dev/null
    echo "Server on port 8888 has been stopped."
    exit 0
  }

http-server $HOME/Developer/dev -p 8888 &
  wait
}

function https-server() {
  trap 'kill $!' EXIT
  http-server --ssl --cert ~/.localhost-ssl/localhost.crt --key ~/.localhost-ssl/localhost.key
}

function run-micro-and-server() {
trap 'kill $PID1 $PID2' EXIT
(start_micro &)
(run-server &)
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"
export PATH="/Users/jordanpeck-snowplow/Documents/kafka_2.13-3.9.1/bin:$PATH"

export NEON_API_KEY="{{NEON_API_KEY}}"


source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Bind Ctrl+R to FZF command history search
bindkey '^R' fzf-history-widget

#[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Aliases
alias pip=pip3
alias python=python3
alias authy="$HOME/Developer/authy"
alias snowplow-tracking-cli="$HOME/snowplow-tracking-cli"
alias cat="bat"
alias zz="z -"
alias c="cursor ."
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'
alias ls="eza --no-permissions --git -l -a --no-user --git-repos --color=always --icons=always --header --group-directories-first -s Name"
alias oc='cursor $(fzf -m --preview="bat --color=always {}")'
alias uuidgenl="uuidgen | tr '[:upper:]' '[:lower:]'"
alias docker-rm="docker-rmc && docker-rmi"
alias git-prune-merged="git branch --merged | grep -v "\*" | xargs git branch -d"
eval $(thefuck --alias)

# zoxide
eval "$(zoxide init zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

export BAT_THEME=Coldark-Dark

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi


# Java Home
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-15.0.2.jdk/Contents/Home"

#compdef neon
###-begin-neon-completions-###
#
# yargs command completion script
#
# Installation: neon completion >> ~/.zshrc
#    or neon completion >> ~/.zprofile on OSX.
#
_neon_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" neon --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _neon_yargs_completions neon
###-end-neon-completions-###

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
