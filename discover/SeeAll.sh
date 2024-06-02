while true
do
	echo " Scanning For Random Servers "
	zmap -N 5 -p 443 -o ips.txt
	echo " [+] Pulling URLs From IP [+] "
	gdn ips.txt | awk '{print $2}' | sort -u > target.txt
		echo " [+] Grabbing info[+] "
	cat target.txt | httpx -sc -title | anew database.txt
		echo " [+] Parsing [+] "
	cat database.txt | grep "200" | awk '{print $1}' | anew all.txt
	rm ips.txt
	rm target.txt
	echo " [!] LOOP [!] "
	killall gdn
done
