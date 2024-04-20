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

if [ "$1" == "--scan" ]; then
    vuln1
elif [ "$1" == "--exploit" ]; then
    vuln2
else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi

