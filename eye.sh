#!/bin/bash
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`
echo "${red}"
echo "USE: -d domain.com"
echo "     -f file_of_domains.txt"

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
echo "${cyan} [x] XSS Started [x] ${reset}"
cat output/$domain/raw_urls.txt | gf xss | sort | uniq > output/$domain/xss.txt
#cat output/$domain/xss.txt | trashcompactor > output/$domain/xss_alive.txt #FIX
#cat output/$domain/xss_alive.txt | gxss -c 100 -o output/$domain/gxss_dump.txt 
cat output/$domain/xss.txt | gxss -c 100 -o output/$domain/gxss_dump.txt

#cat output/$domain/gxss_dump.txt | sort -u | tools/dalfox/./dalfox pipe >> output/$domain/VULN-xss.txt
echo "${green}Find em bugs! Bye ~Eyezik${reset}"
