# Main Aliases Configuration
# This file contains the primary command aliases

# =============================================================================
# Basic Command Replacements
# =============================================================================
alias pip=pip3
alias python=python3
alias cat="bat"
alias ls="eza --no-permissions --git -l -a --no-user --git-repos --color=always --icons=always --header --group-directories-first -s Name"

# =============================================================================
# Navigation & File Operations
# =============================================================================
alias zz="z -"                                                    # Jump back with zoxide
alias c="cursor ."                                                # Open current directory in Cursor
alias oc='cursor $(fzf -m --preview="bat --color=always {}")'    # Open file with fzf + Cursor

# =============================================================================
# Development Tools
# =============================================================================
alias authy="$HOME/Developer/authy"
alias snowplow-tracking-cli="$HOME/snowplow-tracking-cli"

# =============================================================================
# Git Utilities
# =============================================================================
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'
alias git-prune-merged="git branch --merged | grep -v "\*" | xargs git branch -d"

# =============================================================================
# Docker Utilities
# =============================================================================
alias docker-rm="docker-rmc && docker-rmi"

# =============================================================================
# Utilities
# =============================================================================
alias uuidgenl="uuidgen | tr '[:upper:]' '[:lower:]'"            # Lowercase UUID generation

# =============================================================================
# Command Correction
# =============================================================================
eval $(thefuck --alias)
