<div align="center">

# macOS Developer Safe Cleaner

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Platform: macOS](https://img.shields.io/badge/Platform-macOS-black.svg)
![Shell: zsh](https://img.shields.io/badge/Shell-zsh-green.svg)

An interactive `zsh` utility for macOS developers to reclaim tens of gigabytes of disk space **without invalidating active browser sessions, IDE logins, `.env` configurations, or source code**.

</div>

---

## Overview

Modern development workflows rapidly accumulate gigabytes of redundant dependency trees, build artifacts, and editor caches. Unlike aggressive system cleaners that wipe browser cookies or application states, **macOS Developer Safe Cleaner** targets strictly regenerable caches and prompts for explicit confirmation (`[y/N]`) at every step.

## Scope & Safety Matrix

| Preserved (Never Modified) | Cleaned (Interactive Confirmation) |
| :--- | :--- |
| **Browser Sessions:** Chrome cookies, passwords, and active logins | **Dependencies:** `node_modules`, `venv`, `.venv` |
| **IDE Authentication:** Cursor and VS Code accounts & extensions | **Build Artifacts:** `.next`, `.next-build`, `dist`, `.turbo`, `__pycache__` |
| **Project Files:** Source code, `.git` history, and `.env` files | **System & App Caches:** `~/Library/Caches`, `~/Library/Logs`, `~/.cache` |
| **Credentials:** macOS Keychain items and `~/.ssh` keys | **Editor Storage:** Cursor caches & bloated AI chat state (`SQLite VACUUM`) |
| — | **Tooling & Trash:** `Homebrew`, `npm`, `pip`, `Docker` caches, and `~/.Trash` |

---

## Installation

Clone the repository and register the `clean` alias in your `zsh` configuration:

```zsh
git clone https://github.com/fdikmen/mac-dev-cleaner.git ~/.mac-dev-cleaner
chmod +x ~/.mac-dev-cleaner/mac-clean.sh
echo 'alias clean="~/.mac-dev-cleaner/mac-clean.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Usage

Run the utility from any working directory:

```zsh
clean
```

The script scans **7 categories** sequentially, calculates the exact disk footprint for each, and waits for confirmation (`y` to clean, `Enter` or `N` to skip).

### Updating

Pull the latest updates from the repository:

```zsh
git -C ~/.mac-dev-cleaner pull
```

### Deep Disk Inspection (Optional)

Manual one-liners to locate large standalone files or directories:

```zsh
# List the top 15 largest directories in your user profile
du -sh ~/* ~/Library/* 2>/dev/null | sort -hr | head -n 15

# Find individual files larger than 50 MB in Documents and Downloads
find ~/Documents ~/Downloads -type f -size +50M -exec ls -lh {} + 2>/dev/null
```

---

## Disclaimer

This utility removes regenerable dependency directories (`node_modules`, `venv`) and build caches that can be restored via standard package managers (`npm install`, `pip install`). Always review the terminal prompts before confirming deletion.

Released under the [MIT License](LICENSE).
