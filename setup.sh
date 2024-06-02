#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
cyan=`tput setaf 6`
reset=`tput sgr0`
echo "${green}The Eye setup${reset}"
echo "${cyab}Programs to Install:${reset}
${green} gf
 gxss
 dalfox
 ffuf
 OpenRedireX
 qsreplace
 parallel
 ghauri
 anew
 subfinder
 waymore
 httpx
 dirsearch
 paramspider
 nuclei
 xray
                                  "
echo "${green}Your best bet is to install these by hand for now, besides xray which if you do put it into the tools/ dir${reset}"
chmod +x eye.sh
if [ ! -d output ]; then
	mkdir output
fi


########## GAU



apt update
apt upgrade
apt install libc6
cd ~/downloads/
git clone https://github.com/tomnomnom/gf.git
cd gf
go mod init github.com/tomnomnom/gf
go mod tidy
go build
cp gf /bin/
git clone https://github.com/1ndianl33t/Gf-Patterns.git
rm *.md
cd ~/
mkdir .gf
cd .gf
mv ~/downloads/Gf-Patterns/*.json ~/.gf/
cd ~/downloads
wget https://github.com/projectdiscovery/httpx/releases/download/v1.6.2/httpx_1.6.2_linux_amd64.zip
rm *.md
unzip httpx_1.6.2_linux_amd64.zip
mv httpx /bin/
wget https://github.com/projectdiscovery/nuclei/releases/download/v3.2.8/nuclei_3.2.8_linux_amd64.zip
rm *.md
unzip nuclei_3.2.8_linux_amd64.zip
mv nuclei /bin/
cd ~/
git clone https://github.com/projectdiscovery/nuclei-templates.git
rm *.md
cd ~/downloads/
git clone https://github.com/projectdiscovery/katana.git
cd katana/cmd
go build
mv katana /bin/
wget https://github.com/projectdiscovery/naabu/releases/download/v2.3.1/naabu_2.3.1_linux_amd64.zip
unzip naabu_2.3.1_linux_amd64.zip
rm *.md
mv naabu /bin/
wget https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz
tar -xvzf anew-linux-amd64-0.1.1.tgz
mv anew /bin/
wget https://github.com/KathanP19/Gxss/releases/download/v4.1/Gxss_4.1_Linux_x86_64.tar.gz
tar -xvzf Gxss_4.1_Linux_x86_64.tar.gz
cp Gxss /bin/
###git clone https://github.com/maurosoria/dirsearch.git --depth 1
pip3 install dirsearch
git clone https://github.com/devanshbatham/paramspider
cd paramspider
pip install .
cd ..
git clone https://github.com/michael1026/trashcompactor.git
cd trashcompactor
go build
mv trashcompactor /bin/
cd ..
wget https://github.com/projectdiscovery/subfinder/releases/download/v2.6.6/subfinder_2.6.6_linux_amd64.zip
unzip subfinder_2.6.6_linux_amd64.zip
mv subfinder /bin/
git clone https://github.com/projectdiscovery/httpx.git
cd httpx/cmd/httpx
go build
mv httpx /bin/
cd ~/downloads/
echo "${cyan}Done${reset}"
