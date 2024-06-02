#!/bin/bash
while true
do
	killall gdn
	clear
	echo "              "
	echo "              "
	echo "           Finding IPs  "
	echo "              "
	echo "              "
	zmap -N 7 -p 443 -o ips.txt -B 4M
	echo " 10 Sec Sleep... yes its needed "
	sleep 10
	cat ips.txt | gdn |awk '{print $2}' | tee targets.txt
	cat targets.txt | sort -u | uniq | tee target.txt
	echo " [+] Grabbing info[+] "
	cat target.txt | anew raw_db.txt
	cat target.txt | httpx -sc -title | anew database.txt
	echo " [+] Parsing [+] "
	cat database.txt | grep "200" | awk '{print $1}' | anew all.txt
	rm ips.txt
	rm target.txt
	cat all.txt
	echo " [!] LOOP [!] "
done
