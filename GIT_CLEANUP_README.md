# Git Branch Cleanup Script

This script mimics the functionality of a PHPStorm extension for cleaning up local git branches that no longer exist on the remote repository.

## What it does

1. **Fetches latest changes** from the remote repository
2. **Identifies stale branches** - local branches that no longer exist on remote
3. **Safely deletes** those branches (with confirmation)

## Files

- `cleanup-branches.sh` - Main cleanup script
- `git-cleanup` - Simple wrapper script for easier access

## Usage

### Basic Usage

```bash
# See what branches would be deleted (dry run)
./cleanup-branches.sh --dry-run

# Actually delete stale branches (safe delete)
./cleanup-branches.sh --delete

# Force delete all stale branches (including unmerged)
./cleanup-branches.sh --force
```

### Using the wrapper script

```bash
# From anywhere in your project
./git-cleanup --dry-run
./git-cleanup --delete
./git-cleanup --force
```

## Setup Options

### Option 1: Add to PATH (Recommended)

Add the project directory to your PATH in your shell profile:

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="/Users/nickforshee/projects/api.jaro:$PATH"
```

Then you can use it from anywhere:
```bash
git-cleanup --dry-run
```

### Option 2: Create an alias

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
alias git-cleanup='/Users/nickforshee/projects/api.jaro/cleanup-branches.sh'
```

### Option 3: Use directly

Navigate to the project directory and run:
```bash
cd /Users/nickforshee/projects/api.jaro
./cleanup-branches.sh --dry-run
```

## Safety Features

- **Dry run by default** - Shows what would be deleted without actually deleting
- **Current branch protection** - Never deletes the branch you're currently on
- **Confirmation prompt** - Asks for confirmation before deleting
- **Safe delete** - Won't delete unmerged branches unless `--force` is used
- **Colored output** - Easy to read status messages

## Example Output

```
[INFO] Fetching latest changes from remote...
[SUCCESS] Remote fetch completed

[INFO] Performing dry run...

[INFO] Branch Summary:
  Current branch: develop
  Total local branches: 5
  Stale branches (not on remote): 2

[WARNING] Stale branches found:
  - feature/user-authentication
    Last commit: a1b2c3d Add user auth feature
    Date: 2 days ago
  - bugfix/login-issue
    Last commit: e4f5g6h Fix login bug
    Date: 1 week ago

[WARNING] The following branches would be deleted:
  - feature/user-authentication
  - bugfix/login-issue

[INFO] Run with --delete flag to actually delete these branches
```

## How it works

1. **Git Repository Check** - Ensures you're in a git repository
2. **Remote Fetch** - Runs `git fetch --prune` to get latest remote info
3. **Branch Analysis** - Compares local branches with remote branches
4. **Stale Detection** - Identifies branches that exist locally but not remotely
5. **Safe Deletion** - Deletes branches with appropriate safety checks

## Troubleshooting

### "Not in a git repository" error
Make sure you're running the script from within a git repository.

### "Failed to delete branch" error
The branch might have unmerged changes. Use `--force` flag to force delete:
```bash
./cleanup-branches.sh --force
```

### Permission denied
Make sure the script is executable:
```bash
chmod +x cleanup-branches.sh
chmod +x git-cleanup
```

## Integration with IDEs

### VS Code
Add to your VS Code settings.json:
```json
{
    "terminal.integrated.env.osx": {
        "PATH": "/Users/nickforshee/projects/api.jaro:${env:PATH}"
    }
}
```

### PHPStorm/IntelliJ
You can create a custom tool in PHPStorm:
1. Go to Settings → Tools → External Tools
2. Add new tool with:
   - Program: `/Users/nickforshee/projects/api.jaro/cleanup-branches.sh`
   - Arguments: `--dry-run`
   - Working directory: `$ProjectFileDir$`

## Regular Maintenance

Consider running this script regularly to keep your local repository clean:

```bash
# Weekly cleanup
git-cleanup --delete

# Or add to your git hooks for automatic cleanup
# (Advanced users only)
``` 