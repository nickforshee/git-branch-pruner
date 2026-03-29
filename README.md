# Git Branch Pruner

A collection of useful git scripts and utilities for developers. Currently includes a powerful branch cleanup tool that mimics PHPStorm's branch cleanup functionality.

## 🚀 Quick Install

### Option 1: One-liner install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/nickforshee/git-branch-pruner/main/install.sh | bash
```

### Option 2: Manual install
```bash
git clone https://github.com/nickforshee/git-branch-pruner.git
cd git-branch-pruner
chmod +x install.sh
./install.sh
```

## 🛠️ What's Included

### Git Branch Pruner (`git-branch-pruner`)
A powerful tool that identifies and safely removes local git branches that no longer exist on the remote repository.

**Features:**
- 🔍 **Smart Detection** - Identifies branches that exist locally but not remotely
- 🛡️ **Safety First** - Dry run by default, confirmation prompts, current branch protection
- 🎨 **Beautiful Output** - Colored status messages and detailed branch information
- ⚡ **Fast & Efficient** - Uses git's native commands for optimal performance

## 📖 Usage

After installation, you can use the tools from any git repository:

```bash
# See what branches would be deleted (safe)
git-branch-pruner --dry-run

# Actually delete stale branches (with confirmation)
git-branch-pruner --delete

# Force delete all stale branches (including unmerged)
git-branch-pruner --force

# Get help
git-branch-pruner --help
```

## 🎯 Example Output

```
[INFO] Fetching latest changes from remote...
[SUCCESS] Remote fetch completed

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

## 🔧 Installation Details

The installer will:
1. Copy scripts to `~/git-branch-pruner/`
2. Make them executable
3. Add to your PATH or create aliases (your choice)
4. Work with zsh, bash, and other shells

## 🛡️ Safety Features

- **Dry run by default** - Shows what would be deleted without actually deleting
- **Current branch protection** - Never deletes the branch you're currently on
- **Confirmation prompts** - Asks for confirmation before deleting
- **Safe delete** - Won't delete unmerged branches unless `--force` is used
- **Error handling** - Graceful handling of edge cases and errors

## 🏗️ Project Structure

```
git-branch-pruner/
├── branch-pruner.sh         # Main cleanup script
├── git-branch-pruner        # Wrapper script
├── setup-branch-pruner.sh   # Setup script
├── install.sh               # Global installer
├── GIT_CLEANUP_README.md    # Detailed documentation
└── README.md                # This file
```

## 🤝 Contributing

Contributions are welcome! Here's how to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Adding New Utilities

To add a new git utility:

1. Create your script in the repository
2. Make it executable (`chmod +x your-script.sh`)
3. Update the `install.sh` script to include it
4. Update this README with documentation
5. Test thoroughly

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by PHPStorm's branch cleanup functionality
- Built with bash for maximum compatibility
- Designed for developers who love clean git repositories

## 🐛 Issues & Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/Nick-Forshee-Ascent/git-branch-pruner/issues) page
2. Create a new issue with details about your problem
3. Include your operating system and shell information

## 📊 Requirements

- Git (obviously!)
- Bash or Zsh
- Unix-like operating system (macOS, Linux, WSL)

## 🔄 Updates

To update to the latest version:

```bash
cd ~/git-branch-pruner
git pull origin main
```

Or re-run the installer:

```bash
curl -sSL https://raw.githubusercontent.com/Nick-Forshee-Ascent/git-branch-pruner/main/install.sh | bash
```

---

**Made with ❤️ for developers who love clean git repositories**
