# Common utility functions for dotfiles setup

# Define default colors if not already defined
if [[ -z "${RED:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Print header
print_header() {
    local header="$1"
    local width=60
    local padding=$(( (width - ${#header}) / 2 ))
    echo
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}$(printf '%*s%s' $padding '' "$header")${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo
}

# Confirmation prompt
confirm() {
    local prompt="${1:-Are you sure?}"
    if [[ "$INTERACTIVE" != true ]]; then
        return 0
    fi
    read -r -p "$prompt [y/N] " response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Path helpers
join_path() {
    local base="$1"
    local part="$2"
    echo "${base%/}/${part#/}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get timestamp for backups
get_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Check if running in a terminal
is_tty() {
    [[ -t 0 ]] && [[ -t 1 ]]
}
