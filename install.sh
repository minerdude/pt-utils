#!/bin/bash
echo -e "\nInstalling in 3 secs...\n\n"
sleep 3
curl -sL https://deb.nodesource.com/setup_8.x | sudo - bash
sudo apt update && sudo apt upgrade -y
sudo apt install default-jre nodejs nano unzip jq curl
npm install pm2@latest -g
wget "$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases | jq -r '.[0].assets[].browser_download_url')" && \
unzip ProfitTrailer.zip -d .
cd ProfitTrailer
echo -e "Finished. Let's profit!\n\n"
exit 0