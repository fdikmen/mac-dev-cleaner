#!/bin/zsh

# Terminal Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}============================================================${NC}"
echo -e "${CYAN}${BOLD}  macOS Developer Safe Cleaner                              ${NC}"
echo -e "${CYAN}${BOLD}============================================================${NC}"
echo -e "${GREEN}[SAFE]${NC} Browser sessions, cookies, and passwords are preserved."
echo -e "${GREEN}[SAFE]${NC} IDE logins, extensions, .env, and source code are untouched.\n"

BEFORE_KB=$(df -k /System/Volumes/Data | awk 'NR==2 {print $4}')

confirm() {
    echo -ne "${YELLOW}[?] $1 [y/N]: ${NC}"
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# 1. PROJECT DEPENDENCIES
echo -e "${BOLD}[1/7] Scanning Project Dependencies (node_modules, venv, .venv)${NC}"
DEPS_LIST=$(find ~/Documents ~/Desktop \( -name "node_modules" -o -name "venv" -o -name ".venv" \) -type d -prune 2>/dev/null)

if [[ -n "$DEPS_LIST" ]]; then
    DEPS_SIZE=$(echo "$DEPS_LIST" | xargs du -shc 2>/dev/null | tail -n 1 | awk '{print $1}')
    DEPS_COUNT=$(echo "$DEPS_LIST" | wc -l | tr -d ' ')
    echo -e "      Found: ${YELLOW}${DEPS_COUNT} directories${NC} | Total Size: ${YELLOW}${DEPS_SIZE}${NC}"
    if confirm "Remove all node_modules and virtual environments?"; then
        echo "$DEPS_LIST" | xargs rm -rf
        echo -e "      ${GREEN}[OK]${NC} Cleaned.\n"
    else
        echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
    fi
else
    echo -e "      ${GREEN}[OK]${NC} No dependency folders found.\n"
fi

# 2. BUILD ARTIFACTS & CACHES
echo -e "${BOLD}[2/7] Scanning Build Caches (.next, dist, .turbo, __pycache__)${NC}"
BUILD_LIST=$(find ~/Documents ~/Desktop \( -name ".next" -o -name ".next-build" -o -name "dist" -o -name ".turbo" -o -name "__pycache__" \) -type d -prune 2>/dev/null)

if [[ -n "$BUILD_LIST" ]]; then
    BUILD_SIZE=$(echo "$BUILD_LIST" | xargs du -shc 2>/dev/null | tail -n 1 | awk '{print $1}')
    echo -e "      Total Size: ${YELLOW}${BUILD_SIZE}${NC}"
    if confirm "Remove all build cache directories?"; then
        echo "$BUILD_LIST" | xargs rm -rf
        echo -e "      ${GREEN}[OK]${NC} Cleaned.\n"
    else
        echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
    fi
else
    echo -e "      ${GREEN}[OK]${NC} No build caches found.\n"
fi

# 3. SYSTEM, BROWSER & DOT-CACHE
echo -e "${BOLD}[3/7] Checking System, Chrome, and ~/.cache Directories${NC}"
SYS_CACHE=$(du -sh ~/Library/Caches 2>/dev/null | awk '{print $1}')
DOT_CACHE=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}')
echo -e "      ~/Library/Caches: ${YELLOW}${SYS_CACHE:-0B}${NC} | ~/.cache: ${YELLOW}${DOT_CACHE:-0B}${NC}"
if confirm "Clear caches and logs? (Active browser sessions remain intact)"; then
    find ~/Library/Caches -mindepth 2 -delete 2>/dev/null
    rm -rf ~/Library/Caches/Google/Chrome/* 2>/dev/null
    rm -rf ~/.cache/* 2>/dev/null
    rm -rf ~/Library/Logs/* 2>/dev/null
    echo -e "      ${GREEN}[OK]${NC} Cleaned.\n"
else
    echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
fi

# 4. CURSOR EDITOR CACHES & AI CHAT DB
CURSOR_DIR="$HOME/Library/Application Support/Cursor"
if [[ -d "$CURSOR_DIR" ]]; then
    echo -e "${BOLD}[4/7] Checking Cursor Editor Caches & Storage${NC}"
    C_DB_SIZE=$(du -sh "$CURSOR_DIR/User/globalStorage/state.vscdb" 2>/dev/null | awk '{print $1}')
    C_TOTAL=$(du -sh "$CURSOR_DIR" 2>/dev/null | awk '{print $1}')
    echo -e "      Total Cursor Directory: ${YELLOW}${C_TOTAL}${NC} | State DB: ${YELLOW}${C_DB_SIZE:-0B}${NC}"
    if confirm "Clear Cursor caches and prune AI chat history? (Account login is preserved)"; then
        osascript -e 'quit app "Cursor"' 2>/dev/null
        sleep 1
        rm -rf "$CURSOR_DIR/Cache/"* "$CURSOR_DIR/CachedData/"* "$CURSOR_DIR/CachedExtensionVSIXs/"* "$CURSOR_DIR/logs/"* 2>/dev/null
        rm -rf "$CURSOR_DIR/User/globalStorage/anysphere.cursor-agent-worker/"* 2>/dev/null
        if [[ -f "$CURSOR_DIR/User/globalStorage/state.vscdb" ]]; then
            sqlite3 "$CURSOR_DIR/User/globalStorage/state.vscdb" "DELETE FROM cursorDiskKV; DELETE FROM ItemTable WHERE key LIKE 'composer.%' OR key LIKE '%aichat%' OR key LIKE 'aiService.%'; VACUUM;" 2>/dev/null
        fi
        echo -e "      ${GREEN}[OK]${NC} Cursor caches cleared and database vacuumed.\n"
    else
        echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
    fi
fi

# 5. PACKAGE MANAGER CACHES
echo -e "${BOLD}[5/7] Checking Package Manager Caches (Homebrew, npm, pip)${NC}"
NPM_SIZE=$(du -sh ~/.npm 2>/dev/null | awk '{print $1}')
BREW_SIZE=$(du -sh ~/Library/Caches/Homebrew 2>/dev/null | awk '{print $1}')
echo -e "      npm: ${YELLOW}${NPM_SIZE:-0B}${NC} | Homebrew: ${YELLOW}${BREW_SIZE:-0B}${NC}"
if confirm "Prune package manager download caches?"; then
    command -v brew >/dev/null && brew cleanup --prune=all -s 2>/dev/null
    command -v npm >/dev/null && npm cache clean --force 2>/dev/null
    command -v pip3 >/dev/null && pip3 cache purge 2>/dev/null
    echo -e "      ${GREEN}[OK]${NC} Cleaned.\n"
else
    echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
fi

# 6. DOCKER
if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
    echo -e "${BOLD}[6/7] Checking Unused Docker Images & Build Caches${NC}"
    docker system df
    if confirm "Prune all unused Docker images, containers, and build caches?"; then
        docker system prune -a -f
        echo -e "      ${GREEN}[OK]${NC} Docker pruned.\n"
    else
        echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
    fi
else
    echo -e "${BOLD}[6/7] Docker:${NC} Not installed or daemon inactive, skipping.\n"
fi

# 7. TRASH
echo -e "${BOLD}[7/7] Checking Trash${NC}"
TRASH_SIZE=$(du -sh ~/.Trash 2>/dev/null | awk '{print $1}')
echo -e "      Trash Size: ${YELLOW}${TRASH_SIZE:-0B}${NC}"
if [[ "$TRASH_SIZE" != "0B" && -n "$TRASH_SIZE" ]]; then
    if confirm "Permanently empty Trash?"; then
        rm -rf ~/.Trash/* 2>/dev/null
        echo -e "      ${GREEN}[OK]${NC} Trash emptied.\n"
    else
        echo -e "      ${DIM}[SKIP]${NC} Skipped.\n"
    fi
else
    echo -e "      ${GREEN}[OK]${NC} Trash is already empty.\n"
fi

# SUMMARY
AFTER_KB=$(df -k /System/Volumes/Data | awk 'NR==2 {print $4}')
FREED_MB=$(( (AFTER_KB - BEFORE_KB) / 1024 ))
AVAIL_NOW=$(df -h /System/Volumes/Data | awk 'NR==2 {print $4}')

echo -e "${CYAN}${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}Cleanup Complete${NC}"
if (( FREED_MB > 0 )); then
    echo -e "  Space Freed     : ${GREEN}${BOLD}${FREED_MB} MB${NC}"
fi
echo -e "  Available Space : ${CYAN}${BOLD}${AVAIL_NOW}${NC}"
echo -e "${CYAN}${BOLD}============================================================${NC}"
