#!/bin/bash
#eye.sh version 2.4 rebranding ( z.sh )
## colors
BOLD="\e[1m"
CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
black='\033[0;30m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
NC='\033[0m' # No Color
echo -e "$RED$BOLD -                                               - ${NC}"
echo -e "$BLUE$BOLD ░▒▓████████▓▒░       ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$BLUE$BOLD        ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$BLUE$BOLD      ░▒▓██▓▒░       ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$BLUE$BOLD    ░▒▓██▓▒░          ░▒▓██████▓▒░░▒▓████████▓▒░ "
echo -e "$BLUE$BOLD  ░▒▓██▓▒░                  ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$BLUE$BOLD ░▒▓█▓▒░      ░▒▓██▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$BLUE$BOLD ░▒▓████████▓▒░▒▓██▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░ "
echo -e "$RED$BOLD -                                              - ${NC}"
echo -e "$magenta Scan/Exploit $RED[$BLUE z.sh $RED]$magenta - by @$green${BOLD}00xZ$NC /$green${BOLD} Eyezik     "
echo " "
help() {
    echo -e "$BLUE Run --scan before any $magenta(Its sets up all the dir for future tests)${NC}"
    echo " "
    echo -e "$CYAN${BOLD}Usage:${NC}"
    echo -e "    --help           Help:${NC}"
    echo -e "$BLUE    --scan           Subs/GAU/Custom GF     $green |${NC}"
    echo -e "$CYAN    --cscan          Subs/katana/GF         $green |${NC}"
    echo -e "$BLUE    --altscan        Port/DNS/subs/nuclei    $green|${NC}"
    echo -e "$RED${BOLD}    --nuke           Nuclei           $green       |${NC}"
    echo -e "    --or             Open Redirect Vuln Scan $green|${NC}"
    echo -e "    --xss            Scan for XSS $green           |${NC}"

    exit 0
}

if [ "$1" == "--help" ]; then
    help
fi

domain=$2


zcan(){ # Make sure installed these gf patterns in ~/.gf/ https://github.com/00xZ/GFpattren
    echo -e "${CYAN}${BOLD}    ~ ${CYAN}[ ${BLUE}Z${CYAN}.${BLUE}S${CYAN}H ${CYAN}] ~ ${NC}"
    echo -e "$BLUE${BOLD} [!] Running Subfinder/GAU to custom GF patterns"

    if [[ ${domain:0:5} == "https" ]]; then
            domain=${domain:8:${#domain}-8}
    elif [[ ${domain:0:4} == "http" ]]; then
            domain=${domain:7:${domain}-7}
    fi
    if [ -d output/$domain ]; then
        echo -e "$RED${BOLD} [!] An output folder with the same domain name already exists."
        echo -e "$yellow Delete folder:[ $green y $yellow / $RED n $yellow ]: "
        read -p " " delete
        if [[ $delete == 'y' ]]; then
                rm -rf output/$domain
        else
                exit 2
        fi
    fi
    mkdir -p output/$domain/
    echo -e "$magenta Output: output/$domain/raw_urls.txt)"
    echo -e "\n"
    trap : SIGINT
    
    echo -e "$green [+]$RED Sub Finder "
    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
    echo -e "$green [+]$RED Checking Subs for 200 "
    cat output/$domain/subs.txt | httpx -sc | grep "200" |  awk '{print $1 }' | anew output/$domain/subs_200.txt
    echo -e "$green [+]$CYAN Get All Urls "
    gau --subs $domain | anew output/$domain/raw_urls.txt
    echo -e "$green [+]$yellow Getting js/json/jsp "
    #cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    cat output/$domain/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$domain/js.txt


    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With $BLUE(Custom)$CYAN GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit

# Authentication & Secrets (API keys, OAuth tokens, etc.)
#cat output/$domain/raw_urls.txt | gf api-keys | anew output/$domain/auth_and_keys.txt

# httpx -sc -td -title -probe -fhr -location -mc 200

# Vulnerabilities & Exploitable Patterns (RCE, SQLi, XSS, CSRF, IDOR)
cat output/$domain/raw_urls.txt | gf rce | anew output/$domain/rce_patterns.txt
cat output/$domain/raw_urls.txt | gf rce-2 | anew output/$domain/rce_patterns.txt
cat output/$domain/raw_urls.txt | gf ssti | anew output/$domain/ssti.txt
cat output/$domain/raw_urls.txt | gf sqli-error | anew output/$domain/sqli_patterns.txt
cat output/$domain/raw_urls.txt | gf sqli | anew output/$domain/sqli_patterns.txt
cat output/$domain/raw_urls.txt | gf xss | anew output/$domain/xss_patterns.txt
cat output/$domain/raw_urls.txt | gf domxss | anew output/$domain/xss_patterns.txt
cat output/$domain/raw_urls.txt | gf csrf | anew output/$domain/csrf.txt
cat output/$domain/raw_urls.txt | gf redirect | anew output/$domain/or.txt
cat output/$domain/raw_urls.txt | gf or | anew output/$domain/or.txt
cat output/$domain/raw_urls.txt | gf csrf-error | anew output/$domain/csrf.txt
cat output/$domain/raw_urls.txt | gf idor | anew output/$domain/authorization_patterns.txt
cat output/$domain/raw_urls.txt | gf ssrf | anew output/$domain/ssrf.txt
cat output/$domain/raw_urls.txt | gf lfi | anew output/$domain/lfi.txt

    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep --color=auto -E "\.xls|\.xml|\.xlsx|\.pdf|\.sql|\.doc|\.docx|\.pptx|\.txt|\.zip|\.tar.gz|\.tgz|\.bak|\.7z|\.rar" | anew output/$domain/hidden_files.txt

    echo -e "${BOLD} $BLUE [+]$green Done $BLUE [+] "

}
cscan(){ # Make sure installed these gf patterns in ~/.gf/ https://github.com/00xZ/GFpattren
    echo -e "${CYAN}${BOLD}    ~ ${CYAN}[ ${BLUE}Z${CYAN}.${BLUE}S${CYAN}H ${CYAN}] ~ ${NC}"
    echo -e "$BLUE${BOLD} [!] Running Subfinder/GAU to custom GF patterns"

    if [[ ${domain:0:5} == "https" ]]; then
            domain=${domain:8:${#domain}-8}
    elif [[ ${domain:0:4} == "http" ]]; then
            domain=${domain:7:${domain}-7}
    fi
    if [ -d output/$domain ]; then
        echo -e "$RED${BOLD} [!] An output folder with the same domain name already exists."
        echo -e "$yellow Delete folder:[ $green y $yellow / $RED n $yellow ]: "
        read -p " " delete
        if [[ $delete == 'y' ]]; then
                rm -rf output/$domain
        else
                exit 2
        fi
    fi
    mkdir -p output/$domain/
    echo -e "$magenta Output: output/$domain/raw_urls.txt)"
    echo -e "\n"
    trap : SIGINT
    echo -e "$green [+]$RED Sub Finder "
    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
    echo -e "$green [+]$RED Checking Subs for 200 "
    cat output/$domain/subs.txt | httpx -sc | grep "200" |  awk '{print $1 }' | anew output/$domain/subs_200.txt
    echo -e "$green [+]$CYAN Crawling with Katana "
    cat output/$domain/subs_200.txt | katana | anew output/$domain/raw_urls.txt
    echo -e "$green [+]$yellow Getting js/json/jsp "
    #cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    cat output/$domain/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$domain/js.txt


    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With $BLUE(Custom)$CYAN GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit

# Authentication & Secrets (API keys, OAuth tokens, etc.)
#cat output/$domain/raw_urls.txt | gf api-keys | anew output/$domain/auth_and_keys.txt

# httpx -sc -td -title -probe -fhr -location -mc 200

# Vulnerabilities & Exploitable Patterns (RCE, SQLi, XSS, CSRF, IDOR)
cat output/$domain/raw_urls.txt | gf rce | anew output/$domain/rce_patterns.txt
cat output/$domain/raw_urls.txt | gf rce-2 | anew output/$domain/rce_patterns.txt
cat output/$domain/raw_urls.txt | gf ssti | anew output/$domain/ssti.txt
cat output/$domain/raw_urls.txt | gf sqli-error | anew output/$domain/sqli_patterns.txt
cat output/$domain/raw_urls.txt | gf sqli | anew output/$domain/sqli_patterns.txt
cat output/$domain/raw_urls.txt | gf xss | anew output/$domain/xss_patterns.txt
cat output/$domain/raw_urls.txt | gf domxss | anew output/$domain/xss_patterns.txt
cat output/$domain/raw_urls.txt | gf csrf | anew output/$domain/csrf.txt
cat output/$domain/raw_urls.txt | gf redirect | anew output/$domain/or.txt
cat output/$domain/raw_urls.txt | gf or | anew output/$domain/or.txt
cat output/$domain/raw_urls.txt | gf csrf-error | anew output/$domain/csrf.txt
cat output/$domain/raw_urls.txt | gf idor | anew output/$domain/authorization_patterns.txt
cat output/$domain/raw_urls.txt | gf ssrf | anew output/$domain/ssrf.txt
cat output/$domain/raw_urls.txt | gf lfi | anew output/$domain/lfi.txt

    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep --color=auto -E "\.xls|\.xml|\.xlsx|\.pdf|\.sql|\.doc|\.docx|\.pptx|\.txt|\.zip|\.tar.gz|\.tgz|\.bak|\.7z|\.rar" | anew output/$domain/hidden_files.txt

    echo -e "${BOLD} $BLUE [+]$green Done $BLUE [+] "

}
scan_file(){ # Loop through a list of domains from a file
    if [ ! -f "$domain" ]; then
        echo -e "$RED[-] File not found: $domain${NC}"
        exit 1
    fi

    echo -ne "${CYAN}[?] What do you want to name the output folder for the scan? ${NC}"
    read -r outname

    output_dir="output/$outname"
    mkdir -p "$output_dir"
    echo -e "$magenta Output will be stored in: $output_dir$NC\n"

    while IFS= read -r line || [[ -n "$line" ]]; do
        current_domain=$(echo "$line" | sed -E 's|https?://||g' | tr -d '[:space:]')
        echo -e "$BLUE[+] Processing: $current_domain${NC}"

        domain_dir="$output_dir/$current_domain"
        mkdir -p "$domain_dir"

        echo -e "$green [+]$RED Sub Finder "
        subfinder -d "$current_domain" -silent -all | anew "$domain_dir/subs.txt"

        echo -e "$green [+]$RED Checking Subs for 200 "
        cat "$domain_dir/subs.txt" | httpx -sc -td -title -probe -fhr -location  | anew "$domain_dir/subs_deep.txt"

        echo -e "$green [+]$CYAN Get All Urls "
        gau --subs "$current_domain" | anew "$domain_dir/raw_urls.txt"

        echo -e "$green [+]$yellow Getting js/json/jsp "
        cat "$domain_dir/raw_urls.txt" | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew "$domain_dir/js.txt"

        echo -e "$BLUE[+] Done with $current_domain${NC}\n"

    done < "$domain"

    echo -e "$green[✔] Finished scanning all domains in '$domain'.$NC"
}
or() {
    echo -e "$CYAN${BOLD} \n [!] Open Redirect Scan: \n${NC}"
    cat output/$domain/or.txt| uro | qsreplace "https://evil.com" | httpx -silent -fr -mr "https://evil.com" | anew output/$domain/VULN_or.txt
    cat output/$domain/or.txt | nuclei -t ~/nuclei-templates/openRedirect.yaml -c 30 | anew output/$domain/vuln_nuclei_or.txt
    [ -s output/$domain/VULN_or.txt ] && echo -e "$green${BOLD} [+] FOUND VULN Open Redirect [+] Check output/$domain/VULN_or.txt for output ${NC}" || echo -e "$RED [+] No Open Redirect Found[+] ${NC}"
}
nuke() {
    echo -e "$CYAN${BOLD} \n [!] Nuclei CVE scan: \n${NC}"
    nuclei -l output/$domain/subs_200.txt -tags cve -s critical,high,medium,low | anew output/$domain/cve.txt
    [ -s output/$domain/cve.txt ] && echo -e "$green${BOLD} [+] FOUND CVE [+] Check output/$domain/cve.txt for output ${NC}" || echo -e "$RED [+] No CVE Found[+] ${NC}"
}
sqli() {
    echo -e "$CYAN${BOLD} \n [!] Sql Injection scan: \n${NC}"
    cat output/$domain/raw_urls.txt | grep '\.php' | grep '?' | grep '=' |  qsreplace xxx | anew output/$domain/sqli_xxx.txt
    ./injsqli.sh $domain
    ./zql.sh $domain --debug
    ./no-sql-eye.sh $domain --debug
    cat output/$domain/raw_urls.txt | grep 'ogin' | anew output/$domain/login_pages.txt
    #echo -e "$CYAN${BOLD} \n [!] Testing Auth Bypass: \n${NC}"
    #./logSQLIn.sh $domain
    echo -e "$RED${BOLD} \n [x] Nuking... \n${NC}"
    cat output/$domain/sqli.txt | nuclei -t ~/nuclei-templates/errsqli.yaml -dast | anew output/$domain/sqli_vuln.txt
}
crlf() {
    echo -e "$CYAN${BOLD} \n [!] CRLF scan: \n${NC}"
    crlfuzz --list output/$domain/xss.txt --output output/$domain/crlf-results.txt
}
dalfox() {
    echo -e "$CYAN${BOLD} \n [!] DALFOX scan: \n${NC}"
    cat output/$domain/or.txt | dalfox pipe --custom-payload 'https://example.com@evil.com' --custom-payload 'evil.com%2F' --grep 'evil.com' | anew output/$domain/or_vuln.txt
    cat output/$domain/raw_urls.txt | grep "?" | grep "php" | dalfox pipe --custom-payload '{{7*7}}' --grep '49'
}
xss() {
    echo -e "$green${BOLD} \n [!] XSS Scan: \n${NC}"
    echo -e "$CYAN [+] Running URO/GXSS/KXSS${NC}"
    cat output/$domain/xss_patterns.txt | uro  | gxss -c 100 | kxss | anew output/$domain/kxss_xss.txt
    echo -e "$CYAN [+] Parsing${NC}"
    cat output/$domain/kxss_xss.txt | grep -oP '^URL: \K\S+' | sed 's/=.*/=/' | sort -u | anew output/$domain/xss.txt
    echo -e "$CYAN [+] Confirming XSS | dalfox${NC}"
    cat output/$domain/xss.txt | dalfox pipe | anew output/$domain/VULN_xss.txt
    [ -s output/$domain/VULN_xss.txt ] && echo -e "$yellow${BOLD} [+] FOUND VULN XSS [+] Check output/$domain/VULN_xss.txt for output ${NC}" || echo  -e "$RED [+] No XSS Found[+] ${NC}"
}

criplord() {

    #mkdir -p output/$domain/
    echo -e "$green${BOLD} \n [!] Alt-Scanning: \n${NC}"
# 1. Subdomain enumeration
echo -e "$CYAN[+] Juicy Subdomain Patterns via Subfinder + DNSX${NC}"
subfinder -d "$domain" -silent | dnsx -silent | cut -d ' ' -f1 | grep --color 'api\|dev\|stg\|test\|admin\|demo\|stage\|pre\|vpn' | anew output/$domain/subs.txt

echo -e "$CYAN[+] From BufferOver.run${NC}"
curl -s "https://dns.bufferover.run/dns?q=.$domain" | jq -r .FDNS_A[] | cut -d',' -f2 | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From Riddler.io${NC}"
curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From RedHunt Labs API${NC}"
curl --request GET --url "https://reconapi.redhuntlabs.com/community/v1/domains/subdomains?domain=$domain&page_size=1000" --header 'X-BLOBR-KEY: API_KEY' | jq '.subdomains[]' -r | anew output/$domain/subs.txt

echo -e "$CYAN[+] From CertSpotter${NC}"
curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From Wayback Machine${NC}"
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From JLDC Anubis API${NC}"
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From crt.sh${NC}"
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From ThreatMiner${NC}"
curl -s "https://api.threatminer.org/v2/domain.php?q=$domain&rt=5" | jq -r '.results[]' | grep -o "\w.*$domain" | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From Anubis again (JSON response)${NC}"
curl -s "https://jldc.me/anubis/subdomains/$domain" | jq -r '.' | grep -o "\w.*$domain" | anew output/$domain/subs.txt

echo -e "$CYAN[+] From ThreatCrowd${NC}"
curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains' | grep -o "\w.*$domain" | anew output/$domain/subs.txt

echo -e "$CYAN[+] From HackerTarget${NC}"
curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | anew output/$domain/subs.txt

echo -e "$CYAN[+] From AlienVault OTX${NC}"
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=100&page=1" | grep -o '"hostname": *"[^"]*' | sed 's/"hostname": "//' | sort -u | anew output/$domain/subs.txt

echo -e "$CYAN[+] From Censys${NC}"
censys subdomains "$domain" | anew output/$domain/subs.txt

echo -e "$CYAN[+] From Subdomain Center${NC}"
curl -s "https://api.subdomain.center/?domain=$domain" | jq -r '.[]' | sort -u | anew output/$domain/subs.txt
    echo -e "$CYAN [+] Subfinder${NC}"
    #subfinder -d "$domain" -all -silent | anew output/$domain/subs.txt

# 2. Permutation-based bruteforcing with shuffledns
    echo -e "$CYAN [+] Shuffledns${NC}"
    shuffledns -d "$domain" -r resolvers.txt -w n0kovo_subdomains_huge.txt | anew output/$domain/subs.txt

# 3. DNS resolution
    echo -e "$CYAN [+] Dnsx${NC}"
    dnsx -l output/$domain/subs.txt -r resolvers.txt -silent | anew output/$domain/resolved.txt

# 4. Port scanning
    echo -e "$CYAN [+] Naabu${NC}"
    naabu -l output/$domain/resolved.txt -nmap -rate 5000 -silent | anew output/$domain/ports.txt

# 5. HTTP probing
    echo -e "$CYAN [+] Httpx${NC}"
    httpx -l output/$domain/ports.txt -silent | anew output/$domain/alive.txt

# 6. Crawling with Katana
    echo -e "$CYAN [+] Katana${NC}"
    katana -list output/$domain/alive.txt -silent -nc -jc -kf all -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -aff | anew output/$domain/urls.txt

# 7. Vulnerability scanning with Nuclei
    echo -e "$CYAN [+] Nuclei${NC}"
    nuclei -l output/$domain/urls.txt -es info,unknown -ept ssl -ss template-spray | anew output/$domain/nuclei.txt
}
if [ "$1" == "--scan" ]; then
    zcan
elif [ "$1" == "--cscan" ]; then
    cscan
elif [ "$1" == "--list" ]; then
    scan_file
elif [ "$1" == "--nuke" ]; then
    nuke
elif [ "$1" == "--sqli" ]; then
    sqli
elif [ "$1" == "--lfi" ]; then
    lfi
elif [ "$1" == "--dalfox" ]; then
    dalfox
elif [ "$1" == "--crlf" ]; then
    crlf
elif [ "$1" == "--altscan" ]; then
    criplord
elif [ "$1" == "--or" ]; then
    or
elif [ "$1" == "--xss" ]; then
    xss

else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi

#grep -E '\?[^=]+=.+$' |
