#!/bin/bash

# Git Branch Pruner Installer
# This script installs git branch pruner utilities globally on your system

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Get the directory where this script is located
# When run via curl, BASH_SOURCE[0] might not work correctly, so we need to handle this case
if [[ "${BASH_SOURCE[0]}" != "" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Fallback to current directory if BASH_SOURCE doesn't work (e.g., when piped through curl)
    SCRIPT_DIR="$(pwd)"
fi

INSTALL_DIR="$HOME/git-branch-pruner"

# Check if we're running from the git-branch-pruner directory
is_git_branch_pruner_dir() {
    [[ -f "$SCRIPT_DIR/branch-pruner.sh" ]] && [[ -f "$SCRIPT_DIR/git-branch-pruner" ]]
}

# Clone repository if needed
setup_source_files() {
    # Check if we're running via curl (BASH_SOURCE[0] is empty or doesn't exist)
    if [[ "${BASH_SOURCE[0]}" == "" ]] || [[ ! -f "${BASH_SOURCE[0]}" ]]; then
        print_status "Detected curl execution. Cloning repository..."
        FORCE_CLONE=true
    elif ! is_git_branch_pruner_dir; then
        print_status "Not running from git-branch-pruner directory. Cloning repository..."
        FORCE_CLONE=true
    fi
    
    if [[ "$FORCE_CLONE" == "true" ]]; then
        # Create a temporary directory for cloning
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Clone the repository
        git clone https://github.com/Nick-Forshee-Ascent/git-branch-pruner.git
        cd git-branch-pruner
        
        # Update SCRIPT_DIR to point to the cloned directory
        SCRIPT_DIR="$(pwd)"
        
        print_success "Repository cloned to temporary directory"
    fi
}

# Detect shell profile
detect_shell_profile() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        if [[ -f "$HOME/.bash_profile" ]]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}

SHELL_PROFILE=$(detect_shell_profile)

print_status "Git Branch Pruner Installer"
echo "======================"
echo

# Setup source files first
setup_source_files

print_status "Script directory: $SCRIPT_DIR"
print_status "Install directory: $INSTALL_DIR"
print_status "Shell profile: $SHELL_PROFILE"
echo

# Create install directory
if [[ ! -d "$INSTALL_DIR" ]]; then
    print_status "Creating install directory..."
    mkdir -p "$INSTALL_DIR"
fi

# Copy scripts to install directory
print_status "Copying scripts to install directory..."
cp "$SCRIPT_DIR"/*.sh "$INSTALL_DIR/"
cp "$SCRIPT_DIR"/git-branch-pruner "$INSTALL_DIR/"
cp "$SCRIPT_DIR"/*.md "$INSTALL_DIR/" 2>/dev/null || true

# Make scripts executable
print_status "Making scripts executable..."
chmod +x "$INSTALL_DIR"/*.sh "$INSTALL_DIR"/git-branch-pruner

print_success "Scripts copied and made executable!"

# Ask user for setup preference
echo
echo "Choose setup option:"
echo "1) Add to PATH (recommended - allows running 'git-branch-pruner' from anywhere)"
echo "2) Create alias (alternative - allows running 'git-branch-pruner' from anywhere)"
echo "3) Both (PATH + alias)"
echo "4) Skip setup (use scripts directly from $INSTALL_DIR)"
echo

# Check if stdin is available for reading
if [ -t 0 ]; then
    # Interactive mode - stdin is available
    read -p "Enter your choice (1-4): " choice
else
    # Non-interactive mode (e.g., piped through curl)
    # Try to read from /dev/tty if available
    if [ -e /dev/tty ]; then
        read -p "Enter your choice (1-4): " choice < /dev/tty
    else
        # Fallback: use default option
        print_warning "Cannot read user input. Using default option (add to PATH)."
        choice=1
    fi
fi

case $choice in
    1)
        # Add to PATH
        if grep -q "$INSTALL_DIR" "$SHELL_PROFILE" 2>/dev/null; then
            print_warning "PATH already contains the install directory"
        else
            echo "" >> "$SHELL_PROFILE"
            echo "# Git Branch Pruner" >> "$SHELL_PROFILE"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_PROFILE"
            print_success "Added git-branch-pruner directory to PATH in $SHELL_PROFILE"
        fi
        ;;
    2)
        # Create alias
        if grep -q "alias git-branch-pruner=" "$SHELL_PROFILE" 2>/dev/null; then
            print_warning "Alias already exists in $SHELL_PROFILE"
        else
            echo "" >> "$SHELL_PROFILE"
            echo "# Git Branch Pruner Alias" >> "$SHELL_PROFILE"
            echo "alias git-branch-pruner='$INSTALL_DIR/branch-pruner.sh'" >> "$SHELL_PROFILE"
            print_success "Added git-branch-pruner alias to $SHELL_PROFILE"
        fi
        ;;
    3)
        # Both PATH and alias
        if grep -q "$INSTALL_DIR" "$SHELL_PROFILE" 2>/dev/null; then
            print_warning "PATH already contains the install directory"
        else
            echo "" >> "$SHELL_PROFILE"
            echo "# Git Branch Pruner" >> "$SHELL_PROFILE"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_PROFILE"
            print_success "Added git-branch-pruner directory to PATH in $SHELL_PROFILE"
        fi
        
        if grep -q "alias git-branch-pruner=" "$SHELL_PROFILE" 2>/dev/null; then
            print_warning "Alias already exists in $SHELL_PROFILE"
        else
            echo "" >> "$SHELL_PROFILE"
            echo "# Git Branch Pruner Alias" >> "$SHELL_PROFILE"
            echo "alias git-branch-pruner='$INSTALL_DIR/branch-pruner.sh'" >> "$SHELL_PROFILE"
            print_success "Added git-branch-pruner alias to $SHELL_PROFILE"
        fi
        ;;
    4)
        print_status "Skipping setup. You can run the scripts directly:"
        echo "  $INSTALL_DIR/branch-pruner.sh --dry-run"
        echo "  $INSTALL_DIR/git-branch-pruner --dry-run"
        ;;
    *)
        print_warning "Invalid choice. Skipping setup."
        ;;
esac

echo
print_success "Installation complete!"
echo
print_status "Next steps:"
echo "1. Restart your terminal or run: source $SHELL_PROFILE"
echo "2. Test the script: git-branch-pruner --dry-run"
echo "3. Read the documentation: cat $INSTALL_DIR/GIT_CLEANUP_README.md"
echo
print_status "Usage examples:"
echo "  git-branch-pruner --dry-run     # See what would be deleted"
echo "  git-branch-pruner --delete      # Delete stale branches"
echo "  git-branch-pruner --force       # Force delete all stale branches"
echo "  git-branch-pruner --help        # Show help"
echo
print_status "To uninstall, simply remove the lines from $SHELL_PROFILE and delete $INSTALL_DIR"

# Clean up temporary directory if it was created
if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
    print_status "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
fi
