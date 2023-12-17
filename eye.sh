#!/bin/bash
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`
echo "Usage: ./eye.sh -d domain.com -f custom_file.txt -c cookies"
echo "domain.com        --- The domain for which you want to test"
echo "custom_file.txt   --- Optional argument. You give your own custom URLs instead of using gau"
echo "${cyan} 

	[EYE]
			                                                
${green}- By Eyezik ${reset}
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
	echo "${red}An output folder with the same domain name already exists.${reset}"
	read -p "Would you like to delete that folder and start fresh[y/n]: " delete
	if [[ $delete == 'y' ]]; then
		rm -rf output/$domain
	else 
		exit 2
	fi
fi
mkdir output/$domain
if [[ $file == "" ]]; then
	read -p "Check subdomains? [y/n]: " sub
	echo "${cyan}Fetching URLs using GAU (This may take some time depending on the domain. You can check the output generated till now at output/$domain/raw_urls.txt)"
	echo -e "\n${yellow}If you don't want to wait, and want to test for the output generated till now.\n1. Exit this process\n2. Copy the output/$domain/raw_urls.txt to some other location outside of $domain folder\n3. Supply the file location as the third argument.\nEg ./eye.sh domain.com -f path/to/raw_urls.txt"
	if [[ $sub == 'y' || $sub == 'Y' ]]; then
		trap : SIGINT
		gau_s $domain > output/$domain/raw_urls.txt
	else 
		trap : SIGINT
		gau $domain > output/$domain/raw_urls.txt
	fi

	echo -e "${green}Done${reset}\n"
else 
	cat $file > output/$domain/raw_urls.txt
fi
uniq output/$domain/raw_urls.txt | grep "?" | sort | qsreplace ""  > output/$domain/temp-parameterised_urls.txt
uniq output/$domain/raw_urls.txt | grep "?" | sort > output/$domain/gxss_tmp.txt
cat output/$domain/gxss_tmp.txt | grep "=" >> output/$domain/gxss.txt
cat output/$domain/temp-parameterised_urls.txt | grep "=" >> output/$domain/parameterised_urls.txt
cat output/$domain/parameterised_urls.txt | qsreplace "'" > output/$domain/sqli.txt
cat output/$domain/gxss.txt | ~/Gxss/./gxss -c 100 -o output/$domain/g_dump.txt
cat output/$domain/g_dump.txt | sort -u | ~/dalfox/./dalfox pipe >> output/$domain/dalfox_dump
cat output/$domain/dalfox_dump
echo "Done"
