#!/bin/bash
echo -e "\nInstalling in 3 secs...\n\n"
sleep 3
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt update && sudo apt upgrade -y
sudo apt install default-jre nodejs nano unzip jq curl
npm install pm2@latest -g
rm -f ProfitTrailer.zip
wget "$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url')" && \
unzip ProfitTrailer.zip
#Aliases
if grep -q "#alias-pt" .bash_aliases; then
	echo -e "\nAliases already done."
else
	echo -e "#alias-pt\nalias update='sudo apt update'\nalias upgrade='sudo apt upgrade'\nalias clean='sudo apt clean && sudo apt autoclean && sudo apt autoremove'\nalias upgrades='apt list --upgradable'\nalias pmls='pm2 ls'\nalias ptupd='rm temp/ProfitTrailer.zip && wget -P temp/ "$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url')" && unzip ProfitTrailer.zip -d temp/ && ptstop && mv temp/ProfitTrailer/ProfitTrailer.jar ProfitTrailer/ && cd ~'\nalias ptstart='cd ~/ProfitTrailer/ && pm2 start pm2-ProfitTrailer.json && cd ~'\nalias ptstop='pm2 stop profit-trailer'\nalias ptrestart='pm2 restart profit-trailer'/nalias ptdel='pm2 delete profit-trailer'/nalias='pm2 logs profit-trailer --lines 2000'" | tee -a ~/.bash_aliases
	source ~/.bashrc
fi
cd ProfitTrailer
sudo sed -i 's/Xmx512m/Xmx256m/' pm2-ProfitTrailer.json
sudo sed -i 's/Xms512m/Xms256m/' pm2-ProfitTrailer.json

echo -e "Finished. Let's profit!\n\n"
exit 0