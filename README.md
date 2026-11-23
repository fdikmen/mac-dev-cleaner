<div align="center">

# macOS Developer Safe Cleaner

[![License: MIT](.github/badges/license.svg)](LICENSE)
![Platform: macOS](.github/badges/platform.svg)
![Shell: zsh](.github/badges/shell.svg)

An interactive `zsh` utility designed for macOS developers to reclaim tens of gigabytes of disk space **without invalidating active browser sessions, IDE logins, `.env` configurations, or source code**.

</div>

---

## Overview

Modern development workflows rapidly accumulate gigabytes of redundant dependency trees, build artifacts, and editor caches. Unlike aggressive system cleaners that wipe browser cookies or application states, **macOS Developer Safe Cleaner** targets strictly regenerable caches and prompts for explicit confirmation (`[y/N]`) at every step.

## Scope & Safety Matrix

<table>
  <thead>
    <tr>
      <th>Preserved (Never Modified)</th>
      <th>Cleaned (Interactive Confirmation)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Browser Sessions:</strong> Chrome cookies, passwords, and active logins</td>
      <td><strong>Dependencies:</strong> <code>node_modules</code>, <code>venv</code>, <code>.venv</code></td>
    </tr>
    <tr>
      <td><strong>IDE Authentication:</strong> Cursor and VS Code accounts &amp; extensions</td>
      <td><strong>Build Artifacts:</strong> <code>.next</code>, <code>.next-build</code>, <code>dist</code>, <code>.turbo</code>, <code>__pycache__</code></td>
    </tr>
    <tr>
      <td><strong>Project Files:</strong> Source code, <code>.git</code> history, and <code>.env</code> files</td>
      <td><strong>System &amp; App Caches:</strong> <code>~/Library/Caches</code>, <code>~/Library/Logs</code>, <code>~/.cache</code></td>
    </tr>
    <tr>
      <td><strong>Credentials:</strong> macOS Keychain items and <code>~/.ssh</code> keys</td>
      <td><strong>Editor Storage:</strong> Cursor caches &amp; bloated AI chat state (<code>SQLite VACUUM</code>)</td>
    </tr>
    <tr>
      <td></td>
      <td><strong>Tooling &amp; Trash:</strong> <code>Homebrew</code>, <code>npm</code>, <code>pip</code>, <code>Docker</code> caches, and <code>~/.Trash</code></td>
    </tr>
  </tbody>
</table>

---

## Installation

Run the following commands in your macOS Terminal to install globally and register the `clean` alias:

```zsh
git clone https://github.com ~/.mac-dev-cleaner
chmod +x ~/.mac-dev-cleaner/mac-clean.sh
echo 'alias clean="~/.mac-dev-cleaner/mac-clean.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Usage

Execute the command from any working directory:

```zsh
clean
```

The utility scans 7 categories sequentially, calculates the exact disk footprint for each, and waits for confirmation (`y` to clean, `Enter` or `N` to skip).

### Updating

To pull the latest changes from the repository:

```zsh
git -C ~/.mac-dev-cleaner pull
```

### Optional: Deep Disk Inspection One-Liners

If you need to locate large standalone files or directories manually:

```zsh
# List top 15 largest directories in your user profile
du -sh ~/* ~/Library/* 2>/dev/null | sort -hr | head -n 15

# Find individual files larger than 50 MB in Documents and Downloads
find ~/Documents ~/Downloads -type f -size +50M -exec ls -lh {} + 2>/dev/null
```

---

## Disclaimer

This script deletes regenerable dependency directories (`node_modules`, `venv`) and build caches that can be restored using standard package managers (`npm install`, `pip install`). Always review the terminal prompts before confirming deletion. Distributed under the [MIT License](LICENSE).
