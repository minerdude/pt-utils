#!/bin/bash

RED='tput setaf 1'
YELLOW='tput setaf 3'
BLUE='tput setaf 4'
CYANBACK='tput setab 6'
BOLD='tput bold'
RESET='tput sgr0'

function ProgressBar {
# Process data
	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done
# Build progressbar string lengths
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")

printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"

}

echo -e "\n\n"
$CYANBACK ; $YELLOW ; $BOLD ; echo "ProfitTrailer Installer Script 1.0" ; $RESET
echo -e "\n"
if [ -d "~/ProfitTrailer" ]; then
	$RED ; echo -e "\nProfitTrailer already installed!\n" ; $RESET
	exit 0
fi
$YELLOW ; $BOLD; echo -e "\nInstalling in 5 secs...\nIf you want to stop it press CTRL+ C\n" ; $RESET
sleep 5
$YELLOW ; $BOLD ; echo -e "Installing... Please wait..."
ProgressBar 1 100
sleep 1
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash - > /dev/null 2>&1
ProgressBar 5 100
sudo apt update > /dev/null 2>&1  && sudo apt upgrade -y > /dev/null 2>&1
ProgressBar 10 100
sudo apt install -y default-jre nodejs nano unzip jq curl > /dev/null 2>&1
ProgressBar 15 100
sudo npm install pm2@latest -g > /dev/null 2>&1
ProgressBar 30 100
rm -f ProfitTrailer.zip
wget "$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url')" > /dev/null 2>&1
ProgressBar 55 100
unzip -f ProfitTrailer.zip > /dev/null 2>&1
rm -f ProfitTrailer.zip
ProgressBar 70 100
#Aliases
if grep -Fxq "#alias-pt" ~/.bash_aliases
then
	:
else
	echo -e '#alias-pt\nalias update="sudo apt update"\nalias upgrade="sudo apt upgrade"\nalias clean="sudo apt clean && sudo apt autoclean && sudo apt autoremove"\nalias upgrades="apt list --upgradable"\nalias pmls="pm2 ls"\n'  | tee -a ~/.bash_aliases > /dev/null 2>&1
	echo -e 'alias ptupd="cp -rf ~/ProfitTrailer/ ~/backupPT && rm -rf ~/temp/ && wget -P ~/temp/ $(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url') && unzip ~/temp/ProfitTrailer.zip -d temp/ && ptstop && mv ~/temp/ProfitTrailer/ProfitTrailer.jar ~/ProfitTrailer/ && cd ~"\nalias ptstart="cd ~/ProfitTrailer/ && pm2 start pm2-ProfitTrailer.json && cd ~"\nalias ptstop="pm2 stop profit-trailer"\nalias ptrestart="pm2 restart profit-trailer"\nalias ptdel="pm2 delete profit-trailer"\nalias ptlog="pm2 logs profit-trailer --lines 2000"' | tee -a ~/.bash_aliases > /dev/null 2>&1
	source ~/.bash_aliases
fi
ProgressBar 80 100
cd ProfitTrailer
#pm2 memory
sudo sed -i 's/Xmx512m/Xmx256m/' pm2-ProfitTrailer.json
sudo sed -i 's/Xms512m/Xms256m/' pm2-ProfitTrailer.json
ProgressBar 90 100
#Sysctl Conf
if [ ! -f "/etc/sysctl.d/99-profittrailer.conf" ]; then
	echo -e "\n#Protect Against TCP Time-Wait\nnet.ipv4.tcp_rfc1337 = 1\n" | sudo tee /etc/sysctl.d/99-profittrailer.conf > /dev/null 2>&1
	echo -e "#Latency\nnet.ipv4.tcp_low_latency = 1\nnet.ipv4.tcp_slow_start_after_idle = 0\n" | sudo tee -a /etc/sysctl.d/99-profittrailer.conf > /dev/null 2>&1
	echo -e "#Do less swapping\nvm.swappiness = 10\nvm.dirty_ratio = 10\nvm.dirty_background_ratio = 5\nvm.vfs_cache_pressure = 50\n" | sudo tee -a /etc/sysctl.d/99-profittrailer.conf > /dev/null 2>&1
	sudo sysctl -p /etc/sysctl.d/99-profittrailer.conf > /dev/null 2>&1
fi
ProgressBar 95 100
sleep 1
ProgressBar 100 100
$YELLOW ; $BOLD ; echo -e "\n\nFinished. Let's profit!\n\n" ; $RESET
exit 0