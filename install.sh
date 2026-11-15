#!/usr/bin/env bash
#
# Eye toolkit installer
# Supported: Kali Linux, Debian, Ubuntu (apt-based)
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
# Optional:
#   INSTALL_OPTIONAL=1 ./install.sh
#   TOOLS_DIR="$HOME/tools" ./install.sh
#
# Only install/use these tools on systems and applications you own or are
# explicitly authorized to assess.

set -Eeuo pipefail

# ============================================================================
# TOOL INVENTORY — tools referenced by the supplied Eye script
# ============================================================================
# System packages:
#   curl, wget, git, jq, unzip, build-essential, python3, python3-venv,
#   python3-pip, pipx, golang-go, parallel, grep, sed, coreutils
#
# Go binaries:
#   subfinder, httpx (ProjectDiscovery), katana, nuclei, gau, anew, gf,
#   qsreplace, Gxss, dalfox, crlfuzz, ffuf
#
# Python CLI tools:
#   waymore, uro, dirsearch, paramspider, ghauri
#
# Python/Git repositories:
#   tplmap, SecretFinder
#
# Referenced local/custom tools whose upstream source could not be
# unambiguously identified from the supplied script:
#   LFIscanner, ScanQLi, SqliSniper, trashcompactor, xray_linux_amd64
#   These are reported at the end rather than cloning a guessed repository.
#
# Other data/configuration:
#   GF pattern files (~/.gf)
# ============================================================================

TOOLS_DIR="${TOOLS_DIR:-$HOME/tools}"
GO_BIN="${GOBIN:-$(go env GOPATH 2>/dev/null || printf '%s' "$HOME/go")/bin}"
PYTHON="${PYTHON:-python3}"
INSTALL_OPTIONAL="${INSTALL_OPTIONAL:-0}"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

installed=()
skipped=()
failed=()
manual=()

info() { printf "${CYAN}[+]${NC} %s\n" "$*"; }
ok()   { printf "${GREEN}[✓]${NC} %s\n" "$*"; }
skip() { skipped+=("$*"); printf "${YELLOW}[-]${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}[!]${NC} %s\n" "$*"; }
err()  { printf "${RED}[x]${NC} %s\n" "$*" >&2; }

has() { command -v "$1" >/dev/null 2>&1; }

# Check executable names without confusing Python's unrelated "httpx"
# package with ProjectDiscovery's httpx binary.
is_pd_httpx() {
    has httpx || return 1
    httpx -version 2>&1 | grep -qiE 'projectdiscovery|httpx'
}

run() {
    "$@" || {
        err "Command failed: $*"
        return 1
    }
}

clone_repo() {
    local name="$1" url="$2" dest="$TOOLS_DIR/$1"
    if [[ -d "$dest/.git" ]]; then
        skip "$name already cloned at $dest"
        return 0
    fi
    if [[ -e "$dest" ]]; then
        skip "$name directory exists at $dest (not a Git checkout); leaving it untouched"
        return 0
    fi
    info "Cloning $name"
    if git clone --depth 1 "$url" "$dest"; then
        installed+=("$name (repository)")
        return 0
    else
        failed+=("$name (git clone)")
        return 1
    fi
}

pipx_install() {
    local package="$1" command_name="$2"
    if has "$command_name"; then
        skip "$command_name already installed"
        return 0
    fi
    info "Installing Python tool: $package"
    if pipx install "$package"; then
        installed+=("$command_name")
    else
        failed+=("$command_name (pipx)")
        return 1
    fi
}

go_install() {
    local name="$1" module="$2"
    if [[ "$name" == "httpx" ]]; then
        if is_pd_httpx; then skip "ProjectDiscovery httpx already installed"; return 0; fi
    elif has "$name"; then
        skip "$name already installed"
        return 0
    fi
    info "Installing Go tool: $name"
    if GOBIN="$GO_BIN" go install "$module"; then
        installed+=("$name")
    else
        failed+=("$name (go install)")
        return 1
    fi
}

install_repo_requirements() {
    local name="$1" dest="$TOOLS_DIR/$1"
    [[ -d "$dest" ]] || return 0
    if [[ -f "$dest/requirements.txt" ]]; then
        info "Installing Python requirements for $name in its own venv"
        if ! "$PYTHON" -m venv "$dest/.venv"; then
            failed+=("$name (venv)")
            return 1
        fi
        if ! "$dest/.venv/bin/pip" install --upgrade pip; then
            failed+=("$name (pip upgrade)")
            return 1
        fi
        if ! "$dest/.venv/bin/pip" install -r "$dest/requirements.txt"; then
            failed+=("$name (requirements)")
            return 1
        fi
    fi
}

# Do not run apt as root unnecessarily; sudo is used only when needed.
if [[ "$(uname -s)" != "Linux" ]]; then
    err "This installer currently supports Linux only."
    exit 1
fi
if ! has apt-get; then
    err "apt-get was not found. Use Kali, Debian, or Ubuntu."
    exit 1
fi
if [[ "$EUID" -eq 0 ]]; then SUDO=(); else
    if ! has sudo; then err "sudo is required to install system packages."; exit 1; fi
    SUDO=(sudo)
fi

printf "\n${CYAN}Eye toolkit installer${NC}\n"
printf "Tools directory: %s\n\n" "$TOOLS_DIR"

# Base dependencies
APT_PACKAGES=(
    ca-certificates curl wget git jq unzip
    build-essential python3 python3-venv python3-pip pipx
    golang-go parallel grep sed coreutils
)
missing_apt=()
for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
        skip "system package $pkg already installed"
    else
        missing_apt+=("$pkg")
    fi
done

if ((${#missing_apt[@]})); then
    info "Installing missing system packages: ${missing_apt[*]}"
    if run "${SUDO[@]}" apt-get update && run "${SUDO[@]}" apt-get install -y "${missing_apt[@]}"; then
        installed+=("system packages: ${missing_apt[*]}")
    else
        failed+=("system packages")
    fi
fi

mkdir -p "$TOOLS_DIR" "$HOME/.gf"
export PATH="$GO_BIN:$HOME/.local/bin:$PATH"
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="$GO_BIN"
mkdir -p "$GO_BIN"

# Persist PATH additions for future interactive shells.
PATH_LINE='export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"'
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -Fq "$PATH_LINE" "$rc"; then
        printf '\n# Eye toolkit paths\n%s\n' "$PATH_LINE" >> "$rc"
    fi
done

# Ensure pipx's executable directory is available in this session.
if has pipx; then
    pipx ensurepath --force >/dev/null 2>&1 || true
    export PATH="$HOME/.local/bin:$PATH"
fi

# Go tools
if has go; then
    go_install subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest || true
    go_install httpx github.com/projectdiscovery/httpx/cmd/httpx@latest || true
    go_install katana github.com/projectdiscovery/katana/cmd/katana@latest || true
    go_install nuclei github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest || true
    go_install gau github.com/lc/gau/v2/cmd/gau@latest || true
    go_install anew github.com/tomnomnom/anew@latest || true
    go_install gf github.com/tomnomnom/gf@latest || true
    go_install qsreplace github.com/tomnomnom/qsreplace@latest || true
    go_install Gxss github.com/KathanP19/Gxss@latest || true
    if [[ -x "$GO_BIN/Gxss" && ! -e "$GO_BIN/gxss" ]]; then ln -s "$GO_BIN/Gxss" "$GO_BIN/gxss"; fi
    go_install dalfox github.com/hahwul/dalfox/v2@latest || true
    go_install crlfuzz github.com/dwisiswant0/crlfuzz@latest || true
    go_install ffuf github.com/ffuf/ffuf/v2@latest || true
    go_install mantra github.com/Brosck/mantra@latest || true
else
    err "Go is unavailable; skipping Go-based tools."
    failed+=("Go toolchain unavailable")
fi

# Python CLI tools. pipx isolates them from the system Python environment.
if has pipx; then
    pipx_install waymore waymore || true
    pipx_install uro uro || true
    pipx_install dirsearch dirsearch || true
    pipx_install paramspider paramspider || true
    pipx_install ghauri ghauri || true
else
    err "pipx is unavailable; skipping Python CLI tools."
    failed+=("pipx unavailable")
fi

# Clone Python-based tools used by the Eye script.
clone_repo tplmap https://github.com/epinna/tplmap.git || true
clone_repo SecretFinder https://github.com/m4ll0k/SecretFinder.git || true
install_repo_requirements tplmap || true
install_repo_requirements SecretFinder || true

# Install GF's standard example patterns and a commonly used community set.
if has gf; then
    GF_EXAMPLES="$(go env GOPATH 2>/dev/null)/pkg/mod/github.com/tomnomnom/gf@"*
    if compgen -G "$GF_EXAMPLES/examples/*.json" >/dev/null; then
        cp -n "$GF_EXAMPLES"/examples/*.json "$HOME/.gf/" 2>/dev/null || true
    fi
fi
if [[ ! -d "$TOOLS_DIR/Gf-Patterns/.git" ]]; then
    clone_repo Gf-Patterns https://github.com/1ndianl33t/Gf-Patterns.git || true
    if [[ -d "$TOOLS_DIR/Gf-Patterns" ]]; then
        find "$TOOLS_DIR/Gf-Patterns" -maxdepth 1 -type f -name '*.json' \
            -exec cp -n {} "$HOME/.gf/" \; 2>/dev/null || true
    fi
else
    skip "Gf-Patterns already cloned"
fi

# Nuclei templates are data, not a separate executable.
if has nuclei; then
    info "Updating Nuclei templates"
    nuclei -update-templates || warn "Could not update Nuclei templates (you can run: nuclei -update-templates)"
fi

# Optional: attempt these only if the user explicitly opts in.
if [[ "$INSTALL_OPTIONAL" == "1" ]]; then
    warn "Optional tools are not guessed or downloaded from unverified URLs."
fi

# Tools called by Eye but not safely attributable to a known upstream URL
# based solely on the supplied script. Add their official repository URLs
# here once confirmed, then they can be installed with clone_repo.
manual+=(
    "LFIscanner — local path tools/LFIscanner/LFIscanner.py; upstream repository needs confirmation"
    "ScanQLi — local path tools/ScanQLi/scanqli.py; upstream repository needs confirmation"
    "SqliSniper — local path tools/SqliSniper/sqlisniper.py; upstream repository needs confirmation"
    "trashcompactor — command referenced by Eye; upstream/package needs confirmation"
    "xray_linux_amd64 — binary expected at tools/xray_linux_amd64; obtain from the vendor's official release"
    "mantra — referenced by Eye; exact upstream project/version needs confirmation"
)

printf "\n${CYAN}================ INSTALL SUMMARY ================${NC}\n"
if ((${#installed[@]})); then
    printf "${GREEN}Installed during this run:${NC}\n"
    printf '  - %s\n' "${installed[@]}"
fi
if ((${#skipped[@]})); then
    printf "${YELLOW}Already present / skipped:${NC}\n"
    printf '  - %s\n' "${skipped[@]}"
fi
if ((${#failed[@]})); then
    printf "${RED}Failed / needs attention:${NC}\n"
    printf '  - %s\n' "${failed[@]}"
fi
printf "\n${YELLOW}Manual items not automatically installed:${NC}\n"
printf '  - %s\n' "${manual[@]}"

printf "\nAdd these paths to your current shell if needed:\n"
printf '  export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"\n'
printf "\nRestart your terminal or run: source ~/.bashrc\n"
printf "Verify tools with: command -v subfinder httpx katana nuclei gau anew gf qsreplace Gxss dalfox crlfuzz ffuf waymore uro dirsearch paramspider ghauri\n"
printf "\nOnly scan assets you own or are explicitly authorized to test.\n"

if ((${#failed[@]})); then
    exit 1
fi
exit 0
