echo "Zmap Installing"
sudo apt-get -y install zmap
echo "Zmap Installed"
echo "GDN Installing"
git clone https://github.com/kmskrishna/gdn.git
cd gdn
go build
mv gdn /bin/
echo "GDN Installed"
echo "Done"
