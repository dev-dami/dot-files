# Dotfiles

This repository contains my personal dotfiles for Linux desktop and development workflow.

## Included Tools

- **Zed** - Editor configuration
- **Kitty** - Terminal emulator
- **i3** - Window manager
- **i3status** - Status bar for i3
- **Polybar** - Status bar
- **Rofi** - Application launcher
- **Dunst** - Notification daemon
- **Picom** - Compositor
- **sxhkd** - Hotkey daemon
- **btop** - System monitor
- **fastfetch** - System information
- **VS Code** - Editor configuration

## Repository Structure

```text
dotfiles/
├── README.md
├── LICENSE
├── .gitignore
├── setup.sh
├── manifests/
│   ├── core.txt
│   ├── optional.txt
│   ├── system-packages.txt
│   └── fonts.txt
├── packages/
│   ├── editor-zed/
│   ├── term-kitty/
│   ├── wm-i3/
│   ├── wm-i3status/
│   ├── bar-polybar/
│   ├── launcher-rofi/
│   ├── notify-dunst/
│   ├── compositor-picom/
│   ├── hotkeys-sxhkd/
│   ├── tools-btop/
│   ├── tools-fastfetch/
│   └── editor-vscode/
└── scripts/
    ├── sync-from-home.sh
    ├── verify.sh
    └── lib/
        ├── common.sh
        ├── detect.sh
        ├── install.sh
        ├── backup.sh
        ├── stow.sh
        └── fonts.sh
```

## Quick Install

1. Clone the repository:
   ```bash
   https://github.com/dev-dami/dot-files.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

## Setup Script Options

The `setup.sh` script supports the following options:

- **Interactive mode** (default): Prompts for confirmation at each step
  ```bash
  ./setup.sh
  ```

- **Non-interactive mode**: Uses safe defaults without prompts
  ```bash
  ./setup.sh --non-interactive
  ```

- **With optional packages**: Install optional packages in addition to core packages
  ```bash
  ./setup.sh --with-optional
  ```

- **Dry run**: Show what would be done without making changes
  ```bash
  ./setup.sh --dry-run
  ```

- **No install**: Skip system package installation (useful if you already have dependencies)
  ```bash
  ./setup.sh --no-install
  ```

## Font Handling

The setup script automatically detects fonts referenced in configuration files and:
1. Checks if fonts are already installed
2. Installs missing fonts through the package manager when available
3. Prints manual installation instructions for fonts not in repositories
4. Refreshes the font cache after installation

Fonts detected in this configuration:
- JetBrainsMono Nerd Font (Kitty, i3, Polybar, Dunst)
- Maple Mono NF (Zed editor and terminal)
- SF Pro Display (Rofi)

## Maintainer Tools

### Sync from Home

To import current machine configs into the repository:

```bash
./scripts/sync-from-home.sh
```

This script will:
- Inspect current machine configs
- Copy them to the appropriate package directories
- Exclude junk and unsafe files
- Print a summary of imported and skipped files

### Verification

To verify the repository structure:

```bash
./scripts/verify.sh
```

This checks:
- Manifest entries exist
- Packages are stowable
- No banned files are tracked
- No secrets or machine junk are present
- Repository structure is consistent

## Adding New Packages

1. Create a new directory under `packages/` following the naming convention: `category-name`
2. Create the appropriate `.config/` structure within the package directory
3. Add the package name to `manifests/core.txt` or `manifests/optional.txt`
4. Update `manifests/system-packages.txt` if the package requires system installation
5. Run `./scripts/sync-from-home.sh` to import existing configs, or manually add config files

## Superrice Integration

### Superrice Scripts Package
This repository includes a `tools-superrice` package with all superrice scripts for enhanced i3 functionality:

- **Session Management**: `superrice-session`, `superrice-lock`
- **Audio Control**: `superrice-audio`
- **Brightness Control**: `superrice-brightness`
- **Screenshots**: `superrice-shot`
- **Layout Management**: `superrice-layout`
- **Wallpaper Management**: `superrice-wal`, `superrice-wallcycle`
- **Other Tools**: `superrice-tips`, `superrice-cava`, `superrice-pointer`, etc.

### Installation
The superrice package is installed by default with the setup script. It will be linked to `$HOME/bin/` via GNU Stow.

### Fallback Behavior
The i3 configuration includes fallback commands for all superrice features. If superrice scripts are not available, the config falls back to standard tools:
- Audio: `wpctl` or `pactl`
- Brightness: `brightnessctl`
- Screenshots: `flameshot` or `import` (ImageMagick)
- Screen lock: `i3lock`

### Required System Packages
These packages are installed automatically by the setup script:
- `pipewire-pulse` or `pulseaudio-utils` (audio)
- `brightnessctl` (brightness control)
- `flameshot` (screenshots)
- `i3lock` (screen locking)
- `playerctl` (media control)
- `dunst` (notifications)
- `pywal` (color generation)
- `xsettingsd` (X settings daemon)
- `xss-lock` (screen locking integration)

## Safety Notes

- **Backups**: The setup script creates backups of conflicting files with `.bak.<timestamp>` extension
- **Secrets**: Never commit secrets, tokens, or credentials to the repository
- **Machine-specific data**: Generated state files, caches, and logs are excluded
- **External scripts**: Some configs (like i3) reference scripts in `$HOME/bin/`. These are not included in the repository and should be managed separately
- **Verification**: Always run `./scripts/verify.sh` before pushing changes

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
