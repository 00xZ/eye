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
                                  "
chmod +x eye.sh
if [ ! -d output ]; then
	mkdir output
fi
echo "${red}Note: You must have go and python 3.7 installed for the tools to work${reset}"
echo "${cyan}Installing gau... ${reset}"
mkdir tools
cd tools
git clone https://github.com/lc/gau.git
echo -e "Building the main.go file.\n${yellow}[Warning] This process fails if you don't have go installed. If you have any error messages below, try again after installing go.${reset}"
cd gau/cmd/gau
go build main.go
chmod +x main
mv main ../../main
cd ../../../..
echo -e "gau(){
	tools/gau/./main \$1
}
gau_s(){
	tools/gau/./main --subs \$1
}
" >> .profile
cp tools/gau/main /bin/gau
echo -e "\n"

echo "${cyan}Installing ffuf... ${reset}"
cd tools
git clone https://github.com/ffuf/ffuf.git
echo -e "Building the main.go file.\n${yellow}[Warning] This process fails if you don't have go installed. If you have any error messages below, try again after installing go.${reset}"
cd ffuf
go build main.go help.go
chmod +x main
cd ../..
echo -e "ffuf(){
	tools/ffuf/./main -u \$1 -w \$2 -b \$3 -c -t 100 
}" >> .profile
echo -e "\n"


echo "${cyan}Installing OpenRedireX... ${reset}"
cd tools 
git clone https://github.com/devanshbatham/OpenRedireX.git
cd ..
echo -e "openredirex(){
	cat $1 | python3 tools/OpenRedireX/openredirex.py -p \$2
}" >> .profile
echo -e "${green}Done${reset}\n"


echo "${cyan}Installing qsreplace...${reset}"
cd tools
git clone https://github.com/tomnomnom/qsreplace
echo -e "Building the main.go file.\n${yellow}[Warning] This process fails if you don't have go installed. If you have any error messages below, try again after installing go.${reset}"
cd qsreplace
go build main.go
cd ../..
echo -e "qsreplace(){
	tools/qsreplace/./main \$1
}" >> .profile
cp tools/qsreplace/main /bin/qsreplace

echo -e "\n"
if [ -d tools ]; then
	source .profile
	echo "Your tools are installed under the tools directory"
	#echo "${green}All set. Now just run SSRFire!${reset}"
else
	echo "${red}Make sure that you edit the 10th line in the eye.sh file. Refer the github README for more details.${reset}"
fi
git clone https://github.com/KathanP19/Gxss
cd Gxss
echo "${green}Installing Gxss${reset}"
go build
cp ~/Gxss/Gxss /bin/Gxss
echo "${cyan}Gxss Installed ${reset}"
cd ~/
git clone https://github.com/hahwul/dalfox
cd dalfox
go build
echo "${green}Installing DalFox${reset}"
cp dalfox /bin/dalfox
cd ..
echo "${cyan}Installed DalFox"${reset}"
python3 -m pip install waymore
git clone https://github.com/tomnomnom/gf.git
cd gf
go build
cp gf /bin/
cd ..
mkdir ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns.git
cp Gf-Patterns/*.json ~/.gf/
echo "${red}Installed All the stit."${reset}"

echo "${yellow}If you encountered any error while installing due to reasons like go/python not installed, remove the tools directory using rm -rf tools, and run the script again."
