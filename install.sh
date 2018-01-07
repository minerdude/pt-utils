#!/bin/bash

if [ -d "~/ProfitTrailer" ]; then
	echo -e "\nProfitTrailer already installed!\n"
	exit 0
fi
echo -e "\nInstalling in 3 secs...\nIf you want to stop it press CTRL+ C.\n\n"
sleep 3
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt update && sudo apt upgrade -y
sudo apt install default-jre nodejs nano unzip jq curl
sudo npm install pm2@latest -g
rm -f ProfitTrailer.zip
wget "$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url')" && \
unzip ProfitTrailer.zip
rm -f ProfitTrailer.zip
#Aliases
if [ grep -q "#alias-pt" ~/.bash_aliases ]; then
	echo -e "\nAliases already created."
else
	echo -e "#alias-pt\nalias update='sudo apt update'\nalias upgrade='sudo apt upgrade'\nalias clean='sudo apt clean && sudo apt autoclean && sudo apt autoremove'\nalias upgrades='apt list --upgradable'\nalias pmls='pm2 ls'\nalias ptupd='rm -rf ~/temp/ && wget -P ~/temp/ \"$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r \'.[0].assets[].browser_download_url\')\" && unzip ~/temp/ProfitTrailer.zip -d temp/ && ptstop && mv ~/temp/ProfitTrailer/ProfitTrailer.jar ~/ProfitTrailer/ && cd ~'\nalias ptstart='cd ~/ProfitTrailer/ && pm2 start pm2-ProfitTrailer.json && cd ~'\nalias ptstop='pm2 stop profit-trailer'\nalias ptrestart='pm2 restart profit-trailer'\nalias ptdel='pm2 delete profit-trailer'\nalias ptlog='pm2 logs profit-trailer --lines 2000'" | tee -a ~/.bash_aliases
	source ~/.bash_aliases
fi
cd ProfitTrailer
#pm2 memory
sudo sed -i 's/Xmx512m/Xmx256m/' pm2-ProfitTrailer.json
sudo sed -i 's/Xms512m/Xms256m/' pm2-ProfitTrailer.json

#Sysctl Conf
if [  -f "/etc/sysctl.d/99-profittrailer.conf" ]; then
	echo -e "\nSysconf already configured.\n"
else
	echo -e "\n#Protect Against TCP Time-Wait\nnet.ipv4.tcp_rfc1337 = 1\n" | sudo tee /etc/sysctl.d/99-profittrailer.conf
	echo -e "#Latency\nnet.ipv4.tcp_low_latency = 1\nnet.ipv4.tcp_slow_start_after_idle = 0\n" | sudo tee -a /etc/sysctl.d/99-profittrailer.conf
	echo -e "#Hugepages\nvm.nr_hugepages = 128\n" | sudo tee -a /etc/sysctl.d/99-profittrailer.conf
	echo -e "#Do less swapping\nvm.swappiness = 10\nvm.dirty_ratio = 10\nvm.dirty_background_ratio = 5\nvm.vfs_cache_pressure = 50\n" | sudo tee -a /etc/sysctl.d/99-profittrailer.conf
	sudo sysctl -p /etc/sysctl.d/99-profittrailer.conf
fi

echo -e "Finished. Let's profit!\n\n"
exit 0