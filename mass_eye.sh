mkdir output/mass_$1 # a tmp PoC for scanning multi targets in one go
cat targets.txt | subfinder -silent | httpx -silent | anew output/mass_$1/subs.txt
cat output/mass_$1/subs.txt | katana | anew output/mass_$1/all_urls.txt
cat output/mass_$1/all_urls.txt | gf xss > output/mass_$1/xss.txt
cat output/mass_$1/all_urls.txt | gf sqli > output/mass_$1/sqli.txt
cat output/mass_$1/all_urls.txt | gf lfi > output/mass_$1/lfi.txt
nuclei -l output/mass_$1/subs.txt -tags cve -s critical,high,medium,low | anew vuln.db
dirsearch -l output/mass_$1/subs.txt -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql.zip,sql.tar.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,log,xml,js,json --deep-recursive --force-recursive --exclude-sizes=0B --random-agent --full-url -o ~/eye/output/mass_$1/hidden_dir.txt
