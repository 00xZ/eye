set -uo pipefail
 
## ---------------------------------------------------------------------
## colors / banner
## ---------------------------------------------------------------------
RED=$(tput setaf 1)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
DIM=$(tput dim)
RESET=$(tput sgr0)
 
log_step()    { echo -e "${RED}${BOLD}[*]${RESET} ${WHITE}$1${RESET}"; }
log_info()    { echo -e "${WHITE}    $1${RESET}"; }
log_success() { echo -e "${RED}${BOLD}[+]${RESET} ${WHITE}$1${RESET}"; }
log_warn()    { echo -e "${RED}${BOLD}[!]${RESET} ${WHITE}$1${RESET}"; }
log_fail()    { echo -e "${RED}${BOLD}[x]${RESET} ${WHITE}$1${RESET}"; }
 
banner() {
cat << "EOF"
${RED}${BOLD} -                                               -
 ░▒▓████████▓▒░       ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░
        ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░
      ░▒▓██▓▒░       ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░
    ░▒▓██▓▒░          ░▒▓██████▓▒░░▒▓████████▓▒░
  ░▒▓██▓▒░                  ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓█▓▒░      ░▒▓██▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓████████▓▒░▒▓██▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░
 -                                              -${RESET}
EOF
echo -e "${WHITE}${BOLD}The Eye setup${RESET}\n"
}
 
## ---------------------------------------------------------------------
## paths
## ---------------------------------------------------------------------
BASE_DIR="$HOME/eye"
TOOLS_DIR="$BASE_DIR/tools"
DL_DIR="$BASE_DIR/.downloads"
BIN_DIR="/usr/local/bin"
 
if [ "$EUID" -ne 0 ]; then SUDO="sudo"; else SUDO=""; fi
 
mkdir -p "$BASE_DIR" "$TOOLS_DIR" "$DL_DIR" "$BASE_DIR/output"
[ -f "$BASE_DIR/eye.sh" ] && chmod +x "$BASE_DIR/eye.sh"
[ -f "$BASE_DIR/z.sh" ]   && chmod +x "$BASE_DIR/z.sh"
 
TOOL_LIST=(gf Gxss dalfox ffuf OpenRedireX qsreplace parallel ghauri anew \
           subfinder waymore httpx dirsearch paramspider nuclei xray uro \
           SqliSniper katana naabu trashcompactor LFIscanner tplmap)
 
## track results for the final summary
declare -A RESULT
 
run_step() {
    # run_step "name" function_name
    local name="$1" fn="$2"
    if "$fn" >/tmp/eye_setup_"$name".log 2>&1; then
        RESULT["$name"]="ok"
        log_success "$name installed"
    else
        RESULT["$name"]="fail"
        log_fail "$name failed — see /tmp/eye_setup_${name}.log"
    fi
}
 
clone_or_pull() {
    # clone_or_pull <repo_url> <dest_dir>
    local repo="$1" dest="$2"
    if [ -d "$dest/.git" ]; then
        git -C "$dest" pull -q
    else
        git clone -q "$repo" "$dest"
    fi
}
 
fetch_zip_release() {
    # fetch_zip_release <url> <zip_name>
    local url="$1" zip="$2"
    wget -q -O "$DL_DIR/$zip" "$url"
    unzip -oq "$DL_DIR/$zip" -d "$DL_DIR/${zip%.zip}"
}
 
## ---------------------------------------------------------------------
## base system deps
## ---------------------------------------------------------------------
setup_base() {
    log_step "Updating system + installing base dependencies"
    $SUDO apt update -y
    $SUDO apt upgrade -y
    $SUDO apt install -y libc6 git curl wget unzip tar build-essential \
        python3 python3-pip python3-venv golang-go jq
}
 
## ---------------------------------------------------------------------
## individual tool installers (each is idempotent)
## ---------------------------------------------------------------------
install_gf() {
    clone_or_pull https://github.com/tomnomnom/gf.git "$TOOLS_DIR/gf"
    (cd "$TOOLS_DIR/gf" && go mod init github.com/tomnomnom/gf 2>/dev/null; go mod tidy && go build -o gf) || return 1
    $SUDO mv "$TOOLS_DIR/gf/gf" "$BIN_DIR/gf"
    mkdir -p "$HOME/.gf"
    clone_or_pull https://github.com/1ndianl33t/Gf-Patterns.git "$TOOLS_DIR/Gf-Patterns"
    cp "$TOOLS_DIR"/Gf-Patterns/*.json "$HOME/.gf/"
}
 
install_httpx() {
    clone_or_pull https://github.com/projectdiscovery/httpx.git "$TOOLS_DIR/httpx"
    (cd "$TOOLS_DIR/httpx/cmd/httpx" && go build -o httpx) || return 1
    $SUDO mv "$TOOLS_DIR/httpx/cmd/httpx/httpx" "$BIN_DIR/httpx"
}
 
install_nuclei() {
    clone_or_pull https://github.com/projectdiscovery/nuclei.git "$TOOLS_DIR/nuclei"
    (cd "$TOOLS_DIR/nuclei/cmd/nuclei" && go build -o nuclei) || return 1
    $SUDO mv "$TOOLS_DIR/nuclei/cmd/nuclei/nuclei" "$BIN_DIR/nuclei"
    clone_or_pull https://github.com/projectdiscovery/nuclei-templates.git "$HOME/nuclei-templates"
}
 
install_katana() {
    clone_or_pull https://github.com/projectdiscovery/katana.git "$TOOLS_DIR/katana"
    (cd "$TOOLS_DIR/katana/cmd/katana" && go build -o katana) || return 1
    $SUDO mv "$TOOLS_DIR/katana/cmd/katana/katana" "$BIN_DIR/katana"
}
 
install_naabu() {
    fetch_zip_release \
        https://github.com/projectdiscovery/naabu/releases/download/v2.3.1/naabu_2.3.1_linux_amd64.zip \
        naabu.zip
    $SUDO mv "$DL_DIR/naabu/naabu" "$BIN_DIR/naabu"
}
 
install_anew() {
    wget -q -O "$DL_DIR/anew.tgz" \
        https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz
    tar -xzf "$DL_DIR/anew.tgz" -C "$DL_DIR"
    $SUDO mv "$DL_DIR/anew" "$BIN_DIR/anew"
}
 
install_gxss() {
    clone_or_pull https://github.com/KathanP19/Gxss.git "$TOOLS_DIR/Gxss"
    (cd "$TOOLS_DIR/Gxss" && go build -o Gxss) || return 1
    $SUDO mv "$TOOLS_DIR/Gxss/Gxss" "$BIN_DIR/Gxss"
}
 
install_subfinder() {
    clone_or_pull https://github.com/projectdiscovery/subfinder.git "$TOOLS_DIR/subfinder"
    (cd "$TOOLS_DIR/subfinder/v2/cmd/subfinder" && go build -o subfinder) || return 1
    $SUDO mv "$TOOLS_DIR/subfinder/v2/cmd/subfinder/subfinder" "$BIN_DIR/subfinder"
}
 
install_dirsearch() {
    pip3 install --upgrade dirsearch
}
 
install_paramspider() {
    clone_or_pull https://github.com/devanshbatham/paramspider.git "$TOOLS_DIR/paramspider"
    (cd "$TOOLS_DIR/paramspider" && pip3 install .)
}
 
install_trashcompactor() {
    clone_or_pull https://github.com/michael1026/trashcompactor.git "$TOOLS_DIR/trashcompactor"
    (cd "$TOOLS_DIR/trashcompactor" && go build -o trashcompactor) || return 1
    $SUDO mv "$TOOLS_DIR/trashcompactor/trashcompactor" "$BIN_DIR/trashcompactor"
}
 
install_ffuf() {
    clone_or_pull https://github.com/ffuf/ffuf.git "$TOOLS_DIR/ffuf"
    (cd "$TOOLS_DIR/ffuf" && go build -o ffuf main.go help.go) || return 1
    $SUDO mv "$TOOLS_DIR/ffuf/ffuf" "$BIN_DIR/ffuf"
}
 
install_openredirex() {
    clone_or_pull https://github.com/devanshbatham/OpenRedireX.git "$TOOLS_DIR/OpenRedireX"
    (cd "$TOOLS_DIR/OpenRedireX" && pip3 install -r requirements.txt 2>/dev/null)
    local profile_line="openredirex(){ cat \$1 | python3 $TOOLS_DIR/OpenRedireX/openredirex.py -p \$2; }"
    grep -qxF "$profile_line" "$HOME/.profile" 2>/dev/null || echo "$profile_line" >> "$HOME/.profile"
}
 
install_qsreplace() {
    clone_or_pull https://github.com/tomnomnom/qsreplace.git "$TOOLS_DIR/qsreplace"
    (cd "$TOOLS_DIR/qsreplace" && go build -o qsreplace main.go) || return 1
    $SUDO mv "$TOOLS_DIR/qsreplace/qsreplace" "$BIN_DIR/qsreplace"
}
 
install_dalfox() {
    clone_or_pull https://github.com/hahwul/dalfox.git "$TOOLS_DIR/dalfox"
    (cd "$TOOLS_DIR/dalfox" && go build -o dalfox) || return 1
    $SUDO mv "$TOOLS_DIR/dalfox/dalfox" "$BIN_DIR/dalfox"
}
 
install_waymore() {
    python3 -m pip install --upgrade waymore
}
 
install_ghauri() {
    clone_or_pull https://github.com/r0oth3x49/ghauri.git "$TOOLS_DIR/ghauri"
    (cd "$TOOLS_DIR/ghauri" && python3 -m pip install --upgrade -r requirements.txt && python3 setup.py install)
}
 
install_xray() {
    fetch_zip_release \
        https://github.com/chaitin/xray/releases/download/1.9.11/xray_linux_amd64.zip \
        xray.zip
    mkdir -p "$TOOLS_DIR/xray"
    cp "$DL_DIR"/xray/* "$TOOLS_DIR/xray/" 2>/dev/null
    chmod +x "$TOOLS_DIR"/xray/xray* 2>/dev/null
}
 
install_lfiscanner() {
    clone_or_pull https://github.com/R3LI4NT/LFIscanner.git "$TOOLS_DIR/LFIscanner"
    (cd "$TOOLS_DIR/LFIscanner" && pip3 install -r requirements.txt)
}
 
install_tplmap() {
    clone_or_pull https://github.com/epinna/tplmap.git "$TOOLS_DIR/tplmap"
    (cd "$TOOLS_DIR/tplmap" && pip3 install -r requirements.txt)
}
 
install_uro() {
    clone_or_pull https://github.com/s0md3v/uro.git "$TOOLS_DIR/uro"
    (cd "$TOOLS_DIR/uro" && python3 setup.py install)
}
 
install_sqlisniper() {
    clone_or_pull https://github.com/danialhalo/SqliSniper.git "$TOOLS_DIR/SqliSniper"
    (cd "$TOOLS_DIR/SqliSniper" && python3 -m pip install -r requirements.txt)
}
 
install_parallel() {
    $SUDO apt install -y parallel
}
 
## ---------------------------------------------------------------------
## main
## ---------------------------------------------------------------------
main() {
    banner
    log_info "Installing into: ${BOLD}${BASE_DIR}${RESET}"
    log_info "Binaries go to:  ${BOLD}${BIN_DIR}${RESET}"
    echo
    log_info "Tools this setup manages:"
    echo -e "${WHITE}$(printf '    %s\n' "${TOOL_LIST[@]}")${RESET}"
    echo
 
    run_step "base-deps"      setup_base
    run_step "gf"             install_gf
    run_step "httpx"          install_httpx
    run_step "nuclei"         install_nuclei
    run_step "katana"         install_katana
    run_step "naabu"          install_naabu
    run_step "anew"           install_anew
    run_step "Gxss"           install_gxss
    run_step "subfinder"      install_subfinder
    run_step "dirsearch"      install_dirsearch
    run_step "paramspider"    install_paramspider
    run_step "trashcompactor" install_trashcompactor
    run_step "ffuf"           install_ffuf
    run_step "OpenRedireX"    install_openredirex
    run_step "qsreplace"      install_qsreplace
    run_step "dalfox"         install_dalfox
    run_step "waymore"        install_waymore
    run_step "ghauri"         install_ghauri
    run_step "xray"           install_xray
    run_step "LFIscanner"     install_lfiscanner
    run_step "tplmap"         install_tplmap
    run_step "uro"            install_uro
    run_step "SqliSniper"     install_sqlisniper
    run_step "parallel"       install_parallel
 
    echo
    echo -e "${RED}${BOLD}==================== SUMMARY ====================${RESET}"
    local ok=0 bad=0
    for name in "${!RESULT[@]}"; do
        if [ "${RESULT[$name]}" == "ok" ]; then
            echo -e "  ${WHITE}${BOLD}[+]${RESET} ${WHITE}${name}${RESET}"
            ((ok++))
        else
            echo -e "  ${RED}${BOLD}[x]${RESET} ${RED}${name}${RESET}"
            ((bad++))
        fi
    done
    echo -e "${RED}${BOLD}==================================================${RESET}"
    echo -e "${WHITE}${BOLD}${ok} succeeded, ${bad} failed.${RESET}"
    if [ "$bad" -gt 0 ]; then
        log_warn "Check the /tmp/eye_setup_<tool>.log files for anything that failed."
    fi
 
    if command -v gf >/dev/null 2>&1; then
        echo
        log_step "Installed gf patterns:"
        gf -list
    fi
 
    echo
    log_success "ALL SET."
}
 
main "$@"
