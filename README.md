# Dotfiles

Personal configuration files for Linux development environment.

## Included Configurations

- **Editor**: Zed, VS Code
- **Terminal**: Kitty, Alacritty, tmux, zellij
- **Prompt**: Starship
- **Window Manager**: i3, i3status, Polybar
- **Launcher**: Rofi
- **Notifications**: Dunst
- **Compositor**: Picom
- **Hotkeys**: sxhkd
- **System Tools**: btop, fastfetch

## Repository Structure

```text
dotfiles/
├── setup.sh                    # Main installation script
├── manifests/                  # Package manifests
├── packages/                   # Configuration packages
│   ├── editor-zed/             # Zed editor config
│   ├── term-kitty/             # Kitty terminal config
│   ├── term-alacritty/         # Alacritty terminal config
│   ├── term-tmux/              # tmux multiplexer config
│   ├── term-zellij/            # zellij multiplexer config
│   ├── prompt-starship/        # Starship prompt config
│   ├── wm-i3/                  # i3 window manager config
│   ├── bar-polybar/            # Polybar config
│   ├── launcher-rofi/          # Rofi launcher config
│   ├── notify-dunst/           # Dunst notifications
│   ├── compositor-picom/       # Picom compositor
│   ├── hotkeys-sxhkd/          # sxhkd hotkeys
│   ├── tools-btop/             # btop config
│   ├── tools-fastfetch/        # fastfetch config
│   ├── tools-superrice/        # Superrice scripts
│   └── editor-vscode/          # VS Code config
└── scripts/                    # Maintenance scripts
    ├── sync-from-home.sh       # Import current configs
    └── verify.sh               # Verify repository integrity
```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dev-dami/dot-files.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

### Setup Options

```bash
./setup.sh --non-interactive    # Skip prompts
./setup.sh --with-optional      # Install optional packages
./setup.sh --dry-run            # Preview changes only
./setup.sh --no-install         # Skip system package installation
```

## Maintenance Scripts

### Sync from Home
Import current machine configurations:
```bash
./scripts/sync-from-home.sh
```

### Verify Repository
Check repository structure and integrity:
```bash
./scripts/verify.sh
```

## License

MIT License. See [LICENSE](LICENSE) for details.
