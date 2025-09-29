# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Q pre block. Keep at the top of this file.
#!/bin/zsh

# =============================================================================
# Powerlevel10k Instant Prompt
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Environment Variables
# =============================================================================

# Load environment variables from .env.local if it exists
[[ -f "$HOME/.dotfiles/.env.local" ]] && source "$HOME/.dotfiles/.env.local"

# Path configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/postgresql@16/bin:$PATH"

# =============================================================================
# Oh-My-Zsh Configuration
# =============================================================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins to load
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Disable compfix warnings
export FUNCNEST=100
ZSH_DISABLE_COMPFIX="true"

# Source Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# Tool Initializations
# =============================================================================

# 1Password CLI
eval "$(op completion zsh)"; compdef _op op

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Zoxide (smart cd replacement)
eval "$(zoxide init zsh)"

# GitHub CLI configuration
export GH_EDITOR="cursor -w"

# =============================================================================
# Load Modular Configurations
# =============================================================================

# Load all alias configurations
for config_file in "$HOME/.dotfiles/shell/aliases"/*.zsh; do
    [[ -r "$config_file" ]] && source "$config_file"
done

# Load all function configurations
for config_file in "$HOME/.dotfiles/shell/functions"/*.zsh; do
    [[ -r "$config_file" ]] && source "$config_file"
done

# Load Zsh-specific configurations
for config_file in "$HOME/.dotfiles/shell/zsh"/*.zsh; do
    [[ -r "$config_file" ]] && source "$config_file"
done

# =============================================================================
# Application-Specific Configurations
# =============================================================================

# Powerlevel10k theme
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Java Home
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-15.0.2.jdk/Contents/Home"

# BAT theme for better syntax highlighting
export BAT_THEME=Coldark-Dark

# =============================================================================
# Final Configurations
# =============================================================================

# Neon completions
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
