#!/bin/bash
# h1-batch.sh - CSV-driven recon batch runner
# Wraps eye.sh (--scan / --cscan ONLY) across all in-scope URL assets from a
# HackerOne scope export CSV. Does not call, modify, or invoke any
# exploitation functions in eye.sh (sqli, xss, or, nuke, dalfox, crlf, criplord).

set -u

RED='\033[0;31m'
CYAN='\033[1;37m'
GREEN='\033[1;32m'
NC='\033[0m'

EYE_SH="./eye.sh"           # path to your existing program
MODE="--scan"                # default recon mode: --scan (zcan) or --cscan (cscan)
CSV=""
PROGRAM_NAME=""
DRY_RUN=0

usage() {
    echo -e "${CYAN}Usage:${NC}"
    echo "  ./h1-batch.sh --h1-csv scope.csv [--cscan] [--program NAME] [--dry-run]"
    echo
    echo "  --h1-csv FILE     HackerOne scope CSV export (required)"
    echo "  --cscan           Use cscan (katana crawl) instead of default scan (subfinder/gau)"
    echo "  --program NAME    Output folder name (default: derived from CSV filename)"
    echo "  --dry-run         Print what would run without executing eye.sh"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --h1-csv) CSV="$2"; shift 2 ;;
        --cscan) MODE="--cscan"; shift ;;
        --scan) MODE="--scan"; shift ;;
        --program) PROGRAM_NAME="$2"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --help|-h) usage ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; usage ;;
    esac
done

[[ -z "$CSV" ]] && { echo -e "${RED}[-] --h1-csv is required${NC}"; usage; }
[[ ! -f "$CSV" ]] && { echo -e "${RED}[-] File not found: $CSV${NC}"; exit 1; }
[[ ! -f "$EYE_SH" ]] && { echo -e "${RED}[-] eye.sh not found at $EYE_SH — edit EYE_SH path at top of this script${NC}"; exit 1; }

if [[ -z "$PROGRAM_NAME" ]]; then
    PROGRAM_NAME=$(basename "$CSV" | sed -E 's/\.[Cc][Ss][Vv]$//')
fi

OUTDIR="h1-batch-output/$PROGRAM_NAME"
mkdir -p "$OUTDIR"

echo -e "${CYAN}[+] Program:${NC} $PROGRAM_NAME"
echo -e "${CYAN}[+] Output:${NC}  $OUTDIR"
echo -e "${CYAN}[+] Mode:${NC}    $MODE (eye.sh recon only)"
echo

# --- CSV parsing ---
# Expected header: identifier,asset_type,instruction,eligible_for_bounty,
#   eligible_for_submission,availability_requirement,confidentiality_requirement,
#   integrity_requirement,max_severity,system_tags,created_at,updated_at
#
# We only take rows where asset_type == URL and eligible_for_submission == true.
# Wildcards (*.example.com) and non-URL asset types (CIDR, MOBILE_APPLICATION,
# OTHER, etc.) are skipped — they aren't domains eye.sh can scan directly.

TARGETS_FILE="$OUTDIR/in_scope_targets.txt"
> "$TARGETS_FILE"

header_skipped=0
while IFS=',' read -r identifier asset_type instruction eligible_for_bounty eligible_for_submission rest; do
    if [[ $header_skipped -eq 0 ]]; then
        header_skipped=1
        continue
    fi

    # skip blank lines
    [[ -z "$identifier" ]] && continue

    # normalize
    asset_type_clean=$(echo "$asset_type" | tr -d '[:space:]')
    elig_clean=$(echo "$eligible_for_submission" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    # skip wildcards and non-URL asset types
    if [[ "$identifier" == \** ]]; then
        continue
    fi
    if [[ "$asset_type_clean" != "URL" ]]; then
        continue
    fi
    if [[ "$elig_clean" != "true" ]]; then
        continue
    fi

    echo "$identifier" >> "$TARGETS_FILE"
done < "$CSV"

sort -u -o "$TARGETS_FILE" "$TARGETS_FILE"
total=$(wc -l < "$TARGETS_FILE" | tr -d '[:space:]')

if [[ "$total" -eq 0 ]]; then
    echo -e "${RED}[-] No in-scope URL targets found (check CSV column order / eligible_for_submission values).${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Found $total in-scope target(s)${NC} -> $TARGETS_FILE"
echo

# --- run recon ---
count=0
while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    count=$((count + 1))
    echo -e "${CYAN}[$count/$total] ${GREEN}eye.sh $MODE $target${NC}"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        continue
    fi

    (
        cd "$OUTDIR" || exit 1
        # eye.sh writes to its own ./output/<domain>/ relative to cwd,
        # so running it from inside OUTDIR nests results at
        # h1-batch-output/<program>/output/<domain>/
        echo "y" | "$(cd - >/dev/null; pwd)/$EYE_SH" "$MODE" "$target"
    )
    echo
done < "$TARGETS_FILE"

echo -e "${GREEN}[✔] Done. Recon results under: $OUTDIR/output/${NC}"
