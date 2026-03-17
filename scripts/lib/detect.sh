# System detection functions

detect_system() {
    log_info "Detecting system configuration..."

    # Detect distro
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="$ID"
        DISTRO_NAME="$NAME"
        DISTRO_VERSION="$VERSION_ID"
    elif command_exists lsb_release; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        DISTRO_NAME=$(lsb_release -sd)
        DISTRO_VERSION=$(lsb_release -sr)
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown"
        DISTRO_VERSION="unknown"
    fi

    # Detect package manager
    if command_exists apt-get; then
        PKG_MANAGER="apt"
        PKG_UPDATE="sudo apt-get update"
        PKG_INSTALL="sudo apt-get install -y"
        PKG_QUERY="dpkg -l"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_QUERY="pacman -Q"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf check-update"
        PKG_INSTALL="sudo dnf install -y"
        PKG_QUERY="dnf list installed"
    elif command_exists yum; then
        PKG_MANAGER="yum"
        PKG_UPDATE="sudo yum check-update"
        PKG_INSTALL="sudo yum install -y"
        PKG_QUERY="yum list installed"
    else
        PKG_MANAGER="unknown"
    fi

    log_success "Detected: $DISTRO_NAME ($DISTRO) using $PKG_MANAGER"
}

check_package() {
    local package="$1"
    case "$PKG_MANAGER" in
        apt)
            dpkg -l | grep -q "^ii  $package " || dpkg -l | grep -q "^ii  $package:"
            ;;
        pacman)
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        dnf|yum)
            $PKG_QUERY "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

check_command() {
    command_exists "$1"
}

check_font() {
    local font="$1"
    fc-list | grep -i "$font" >/dev/null 2>&1
}
