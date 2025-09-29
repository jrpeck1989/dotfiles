# Dotfiles 🏠

A collection of my personal dotfiles for macOS, focused on productivity and development workflow.

## ✨ Features

- **Zsh Configuration**: Powered by Oh-My-Zsh with Powerlevel10k theme
- **Git Configuration**: Optimized aliases and settings
- **Development Tools**: Docker, Vault, Consul, and Snowplow utilities
- **Modern CLI Tools**: fzf, bat, eza, zoxide, and more
- **Modular Structure**: Organized into logical components for easy maintenance

## 🛠 Tools & Applications

### Shell & Terminal
- [Oh-My-Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd replacement

### Productivity Tools
- [bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting
- [eza](https://github.com/eza-community/eza) - Modern ls replacement
- [fd](https://github.com/sharkdp/fd) - Fast find alternative
- [thefuck](https://github.com/nvbn/thefuck) - Command correction tool

### Development
- Git with optimized configuration
- Docker utilities and cleanup functions
- 1Password CLI integration
- Node.js (via nvm)
- Python development tools

## 📁 Structure

```
dotfiles/
├── README.md           # This file
├── install.sh          # Installation script
├── .env.template       # Environment variables template
├── .gitconfig          # Git configuration
├── .gitignore          # Git ignore patterns
├── .profile            # Shell profile
├── .zshrc              # Main Zsh configuration
├── .zprofile           # Zsh profile
├── .zlogin             # Zsh login
├── .p10k.zsh           # Powerlevel10k configuration
├── .yarnrc             # Yarn configuration
├── shell/              # Shell configurations
│   ├── zsh/           # Zsh-specific configs
│   ├── aliases/       # Command aliases
│   └── functions/     # Custom shell functions
├── config/            # Application configs
└── git/              # Git-related configs
```

## 🚀 Installation

### Prerequisites

Install required tools via Homebrew:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install \
  git \
  zsh \
  fzf \
  bat \
  eza \
  fd \
  zoxide \
  thefuck \
  fswatch \
  http-server

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

### Automated Installation

1. Clone this repository:
```bash
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the installation script:
```bash
./install.sh
```

3. Set up environment variables:
```bash
cp .env.template .env.local
# Edit .env.local with your actual values
```

4. Restart your terminal or source the configuration:
```bash
source ~/.zshrc
```

### Manual Installation

If you prefer manual setup:

```bash
# Backup existing dotfiles
mkdir -p ~/.dotfiles-backup
mv ~/.zshrc ~/.dotfiles-backup/ 2>/dev/null || true
mv ~/.gitconfig ~/.dotfiles-backup/ 2>/dev/null || true

# Create symlinks
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/.p10k.zsh ~/.p10k.zsh
# ... (add other symlinks as needed)
```

## ⚙️ Configuration

### Environment Variables

Copy `.env.template` to `.env.local` and fill in your values:

```bash
# Vault configuration
export VAULT_ADDR="your-vault-address"
export GH_TOKEN="your-github-token"
export NEON_API_KEY="your-neon-api-key"
# ... other variables
```

### Git Configuration

Update the `.gitconfig` file with your personal information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🔧 Customization

### Adding New Aliases

Add new aliases to `shell/aliases/` directory:

```bash
echo 'alias myalias="my command"' >> shell/aliases/custom.zsh
```

### Adding New Functions

Create new functions in `shell/functions/`:

```bash
# shell/functions/myfunction.zsh
function myfunction() {
    echo "Hello, $1!"
}
```

### Zsh Plugins

To add new Zsh plugins, edit the `plugins` array in `.zshrc`:

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting your-new-plugin)
```

## 📚 Useful Commands & Aliases

### Git Aliases
- `git lg` - Pretty git log with graph
- `git co` - Checkout
- `git st` - Status

### Custom Aliases
- `c` - Open current directory in Cursor
- `cat` - Uses bat with syntax highlighting
- `ls` - Uses eza with icons and git status
- `zz` - Jump to previous directory (zoxide)
- `oc` - Open file in Cursor using fzf

### Custom Functions
- `docker-rm` - Clean up Docker containers and images
- `run_micro()` - Run Snowplow Micro with file watching
- `vault_auth()` - Authenticate with Vault
- `prod-vault-login()` - Production Vault login

## 🐛 Troubleshooting

### Zsh Completion Issues

If you encounter completion issues:

```bash
# Rebuild completion cache
rm -f ~/.zcompdump*
compinit
```

### Powerlevel10k Configuration

To reconfigure Powerlevel10k:

```bash
p10k configure
```

### Permission Issues

If you encounter permission issues:

```bash
# Fix Oh-My-Zsh permissions
compaudit | xargs chmod g-w,o-w
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

If you have any questions or run into issues, please open an issue on GitHub.

---

*Happy coding! 🚀*
