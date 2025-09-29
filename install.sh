#!/bin/bash
# Dotfiles Installation Script
# Automates the setup of dotfiles and required dependencies

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# =============================================================================
# Helper Functions
# =============================================================================

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" || -L "$file" ]]; then
        print_status "Backing up existing $file"
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ -e "$target" ]]; then
        backup_file "$target"
    fi
    
    print_status "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

# =============================================================================
# Main Installation Functions
# =============================================================================

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS. Manual installation required."
        exit 1
    fi
    
    # Check if Homebrew is installed
    if ! check_command brew; then
        print_error "Homebrew is not installed. Please install it first:"
        print_error '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

install_dependencies() {
    print_status "Installing dependencies via Homebrew..."
    
    local packages=(
        "git"
        "zsh"
        "fzf"
        "bat"
        "eza"
        "fd"
        "zoxide"
        "thefuck"
        "fswatch"
        "http-server"
    )
    
    for package in "${packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            print_success "$package is already installed"
        else
            print_status "Installing $package..."
            brew install "$package"
        fi
    done
    
    print_success "Dependencies installation completed"
}

install_oh_my_zsh() {
    print_status "Checking Oh-My-Zsh installation..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh-My-Zsh is already installed"
    else
        print_status "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh-My-Zsh installed"
    fi
}

install_zsh_plugins() {
    print_status "Installing Zsh plugins..."
    
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Powerlevel10k theme
    if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        print_success "Powerlevel10k is already installed"
    else
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        print_success "Powerlevel10k installed"
    fi
    
    # Zsh autosuggestions
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        print_success "zsh-autosuggestions is already installed"
    else
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    fi
    
    # Zsh syntax highlighting
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        print_success "zsh-syntax-highlighting is already installed"
    else
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    fi
}

create_symlinks() {
    print_status "Creating symlinks for dotfiles..."
    
    # Main dotfiles
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
    create_symlink "$DOTFILES_DIR/.zlogin" "$HOME/.zlogin"
    create_symlink "$DOTFILES_DIR/.profile" "$HOME/.profile"
    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    create_symlink "$DOTFILES_DIR/.yarnrc" "$HOME/.yarnrc"
    
    print_success "Symlinks created"
}

setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [[ ! -f "$DOTFILES_DIR/.env.local" ]]; then
        if [[ -f "$DOTFILES_DIR/env.template" ]]; then
            print_warning "Environment template found. Please copy env.template to .env.local and fill in your values:"
            print_warning "cp $DOTFILES_DIR/env.template $DOTFILES_DIR/.env.local"
        else
            print_warning "No environment template found. You may need to set up environment variables manually."
        fi
    else
        print_success "Environment configuration already exists"
    fi
}

finalize_installation() {
    print_status "Finalizing installation..."
    
    # Set Zsh as default shell if not already
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_status "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
        print_success "Default shell changed to Zsh"
    fi
    
    print_success "Installation completed successfully!"
    print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
    
    if [[ ! -f "$DOTFILES_DIR/.env.local" ]]; then
        print_warning "Don't forget to set up your environment variables in .env.local"
    fi
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    echo "🏠 Dotfiles Installation Script"
    echo "==============================="
    echo
    
    # Ensure we're in the dotfiles directory
    if [[ "$(basename "$PWD")" != "dotfiles" ]]; then
        print_error "Please run this script from the dotfiles directory"
        exit 1
    fi
    
    # Set the dotfiles directory to current directory
    DOTFILES_DIR="$PWD"
    
    check_prerequisites
    install_dependencies
    install_oh_my_zsh
    install_zsh_plugins
    create_symlinks
    setup_environment
    finalize_installation
    
    echo
    print_success "🎉 Dotfiles setup complete! Enjoy your enhanced shell experience!"
}

# Run main function
main "$@"
