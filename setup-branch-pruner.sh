#!/bin/bash

# Setup script for Git Branch Cleanup
# This script helps you integrate the cleanup script into your shell environment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

print_status "Detected shell profile: $SHELL_PROFILE"

# Function to add PATH export
add_to_path() {
    local profile="$1"
    local path_export="export PATH=\"$SCRIPT_DIR:\$PATH\""
    
    if grep -q "$SCRIPT_DIR" "$profile" 2>/dev/null; then
        print_warning "PATH already contains the script directory"
        return 0
    fi
    
    echo "" >> "$profile"
    echo "# Git Branch Cleanup Script" >> "$profile"
    echo "$path_export" >> "$profile"
    
    print_success "Added script directory to PATH in $profile"
}

# Function to add alias
add_alias() {
    local profile="$1"
    local alias_line="alias git-cleanup='$SCRIPT_DIR/cleanup-branches.sh'"
    
    if grep -q "alias git-cleanup=" "$profile" 2>/dev/null; then
        print_warning "Alias already exists in $profile"
        return 0
    fi
    
    echo "" >> "$profile"
    echo "# Git Branch Cleanup Alias" >> "$profile"
    echo "$alias_line" >> "$profile"
    
    print_success "Added git-cleanup alias to $profile"
}

# Main setup function
main() {
    echo "Git Branch Cleanup Setup"
    echo "========================"
    echo
    
    print_status "Script directory: $SCRIPT_DIR"
    print_status "Shell profile: $SHELL_PROFILE"
    echo
    
    # Check if shell profile exists
    if [[ ! -f "$SHELL_PROFILE" ]]; then
        print_warning "Shell profile $SHELL_PROFILE does not exist. Creating it..."
        touch "$SHELL_PROFILE"
    fi
    
    # Ask user for setup preference
    echo "Choose setup option:"
    echo "1) Add to PATH (recommended - allows running 'git-cleanup' from anywhere)"
    echo "2) Create alias (alternative - allows running 'git-cleanup' from anywhere)"
    echo "3) Both (PATH + alias)"
    echo "4) Skip setup (use scripts directly from this directory)"
    echo
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            add_to_path "$SHELL_PROFILE"
            ;;
        2)
            add_alias "$SHELL_PROFILE"
            ;;
        3)
            add_to_path "$SHELL_PROFILE"
            add_alias "$SHELL_PROFILE"
            ;;
        4)
            print_status "Skipping setup. You can run the scripts directly:"
            echo "  $SCRIPT_DIR/cleanup-branches.sh --dry-run"
            echo "  $SCRIPT_DIR/git-cleanup --dry-run"
            ;;
        *)
            print_warning "Invalid choice. Skipping setup."
            ;;
    esac
    
    echo
    print_success "Setup complete!"
    echo
    print_status "Next steps:"
    echo "1. Restart your terminal or run: source $SHELL_PROFILE"
    echo "2. Test the script: git-cleanup --dry-run"
    echo "3. Read the documentation: cat $SCRIPT_DIR/GIT_CLEANUP_README.md"
    echo
    print_status "Usage examples:"
    echo "  git-cleanup --dry-run     # See what would be deleted"
    echo "  git-cleanup --delete      # Delete stale branches"
    echo "  git-cleanup --force       # Force delete all stale branches"
    echo "  git-cleanup --help        # Show help"
}

# Run main function
main "$@" 