#!/bin/bash

# Git Branch Cleanup Script
# This script removes local branches that no longer exist on the remote repository
# It mimics the functionality of a PHPStorm extension for branch cleanup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this script from within a git repository."
        exit 1
    fi
}

# Function to fetch latest changes from remote
fetch_remote() {
    print_status "Fetching latest changes from remote..."
    git fetch --prune
    print_success "Remote fetch completed"
}

# Function to get current branch
get_current_branch() {
    git branch --show-current
}

# Function to get list of local branches (excluding current branch)
get_local_branches() {
    git branch --format='%(refname:short)' | grep -v "$(get_current_branch)"
}

# Function to check if a branch exists on remote
branch_exists_on_remote() {
    local branch_name="$1"
    git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"
}

# Function to get list of branches that don't exist on remote
get_stale_branches() {
    local stale_branches=()

    while IFS= read -r branch; do
        if [ -n "$branch" ] && ! branch_exists_on_remote "$branch"; then
            stale_branches+=("$branch")
        fi
    done < <(get_local_branches)

    echo "${stale_branches[@]}"
}

# Function to delete a branch
delete_branch() {
    local branch_name="$1"
    local force_delete="$2"

    if [ "$force_delete" = "true" ]; then
        git branch -D "$branch_name"
    else
        git branch -d "$branch_name"
    fi
}

# Function to check if a branch is merged
is_branch_merged() {
    local branch_name="$1"
    git branch --merged | grep -q "^[[:space:]]*$branch_name$"
}

# Function to show branch information
show_branch_info() {
    local branch_name="$1"
    local last_commit=$(git log --oneline -1 "$branch_name" --format="%h %s")
    local last_commit_date=$(git log --format="%cr" -1 "$branch_name")

    echo "  - $branch_name"
    echo "    Last commit: $last_commit"
    echo "    Date: $last_commit_date"
}

# Function to show summary
show_summary() {
    local current_branch=$(get_current_branch)
    local total_local_branches=$(get_local_branches | wc -l)
    local stale_branches=($(get_stale_branches))
    local stale_count=${#stale_branches[@]}

    echo
    print_status "Branch Summary:"
    echo "  Current branch: $current_branch"
    echo "  Total local branches: $total_local_branches"
    echo "  Stale branches (not on remote): $stale_count"

    if [ $stale_count -gt 0 ]; then
        echo
        print_warning "Stale branches found:"
        for branch in "${stale_branches[@]}"; do
            show_branch_info "$branch"
        done
    else
        echo
        print_success "No stale branches found!"
    fi
}

# Function to perform dry run
dry_run() {
    print_status "Performing dry run..."
    show_summary

    local stale_branches=($(get_stale_branches))
    local stale_count=${#stale_branches[@]}

    if [ $stale_count -gt 0 ]; then
        echo
        print_warning "The following branches would be deleted:"
        for branch in "${stale_branches[@]}"; do
            echo "  - $branch"
        done
        echo

        # Check for unmerged branches
        local unmerged_branches=()
        for branch in "${stale_branches[@]}"; do
            if ! is_branch_merged "$branch"; then
                unmerged_branches+=("$branch")
            fi
        done

        print_status "Run with --delete flag to actually delete these branches. Note: If branches are not merged, use --force flag to force delete unmerged branches"
    fi
}

# Function to perform actual cleanup
perform_cleanup() {
    local force_delete="$1"
    local stale_branches=($(get_stale_branches))
    local stale_count=${#stale_branches[@]}

    print_status "Deleting $stale_count stale branch(es)..."

    local deleted_count=0
    local failed_count=0

    for branch in "${stale_branches[@]}"; do
        if delete_branch "$branch" "$force_delete"; then
            print_success "Deleted branch: $branch"
            ((deleted_count++))
        else
            print_error "Failed to delete branch: $branch"
            ((failed_count++))
        fi
    done

    echo
    print_success "Cleanup completed!"
    echo "  Branches deleted: $deleted_count"
    if [ $failed_count -gt 0 ]; then
        print_warning "  Branches failed to delete: $failed_count"
        print_warning "  Use --force flag to force delete unmerged branches"
    fi
}

# Function to show help
show_help() {
    echo "Git Branch Cleanup Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --dry-run     Show what would be deleted without actually deleting"
    echo "  --delete      Actually delete stale branches"
    echo "  --force       Force delete branches (even if not merged)"
    echo "  --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --dry-run     # See what branches would be deleted"
    echo "  $0 --delete      # Delete stale branches (safe delete)"
    echo "  $0 --force       # Force delete all stale branches"
    echo
    echo "This script will:"
    echo "  1. Fetch latest changes from remote"
    echo "  2. Identify local branches that no longer exist on remote"
    echo "  3. Delete those branches (with --delete or --force flag)"
    echo
    echo "Safety features:"
    echo "  - Always starts with a dry run unless --delete is specified"
    echo "  - Won't delete the current branch"
    echo "  - Won't delete unmerged branches unless --force is used"
}

# Main script logic
main() {
    local dry_run_flag=false
    local delete_flag=false
    local force_flag=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run_flag=true
                shift
                ;;
            --delete)
                delete_flag=true
                shift
                ;;
            --force)
                force_flag=true
                delete_flag=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Check if we're in a git repository
    check_git_repo

    # Fetch latest changes
    fetch_remote

    # If no flags specified, default to dry run
    if [ "$dry_run_flag" = false ] && [ "$delete_flag" = false ]; then
        dry_run_flag=true
    fi

    # Perform dry run if requested
    if [ "$dry_run_flag" = true ]; then
        dry_run
    fi

    # Perform actual cleanup if requested
    if [ "$delete_flag" = true ]; then
        local stale_branches=($(get_stale_branches))
        local stale_count=${#stale_branches[@]}

        if [ $stale_count -eq 0 ]; then
            print_success "No stale branches to delete!"
        else
            echo
            if [ "$force_flag" = true ]; then
                print_warning "Force delete mode enabled - unmerged branches will be deleted!"
            fi

            # Show the same summary as dry run before asking for confirmation
            print_status "The following branches will be deleted:"
            for branch in "${stale_branches[@]}"; do
                show_branch_info "$branch"
            done
            echo

            read -p "Are you sure you want to delete stale branches? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                perform_cleanup "$force_flag"
            else
                print_status "Cleanup cancelled"
            fi
        fi
    fi
}

# Run main function with all arguments
main "$@"
