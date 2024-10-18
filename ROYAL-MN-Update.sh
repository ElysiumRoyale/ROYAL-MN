#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'elysium_royaled' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop elysium_royaled${NC}"
        elysium_royale-cli stop
        sleep 30
        if pgrep -x 'elysium_royaled' > /dev/null; then
            echo -e "${RED}elysium_royaled daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 elysium_royaled
            sleep 30
            if pgrep -x 'elysium_royaled' > /dev/null; then
                echo -e "${RED}Can't stop elysium_royaled! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your ROYAL Masternode Will be Updated To The Latest Version v1.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'elysiumroyaleauto.sh' | crontab -

#Stop elysium_royaled by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/elysium_royale*
mkdir ROYAL_1.1.0
cd ROYAL_1.1.0
wget https://github.com/ElysiumRoyale/ROYAL/releases/download/v1.1.0/Elysium-Royale-1.1.0-Ubuntu-Daemon.tar.gz
tar -xzvf Elysium-Royale-1.1.0-Ubuntu-Daemon.tar.gz
mv elysium_royaled /usr/local/bin/elysium_royaled
mv elysium_royale-cli /usr/local/bin/elysium_royale-cli
chmod +x /usr/local/bin/elysium_royale*
rm -rf ~/.elysiumroyale/blocks
rm -rf ~/.elysiumroyale/chainstate
rm -rf ~/.elysiumroyale/sporks
rm -rf ~/.elysiumroyale/evodb
rm -rf ~/.elysiumroyale/zerocoin
rm -rf ~/.elysiumroyale/peers.dat
cd ~/.elysiumroyale/
wget https://github.com/ElysiumRoyale/ROYAL/releases/download/v1.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.elysiumroyale/bootstrap.zip ~/ROYAL_1.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.elysiumroyale/elysiumroyale.conf

echo "addnode=128.199.38.12
addnode=128.199.33.211
addnode=128.199.40.228
addnode=128.199.40.210
addnode=128.199.43.242
addnode=165.232.91.211" >> ~/.elysiumroyale/elysiumroyale.conf

#start elysium_royaled
elysium_royaled -daemon

printf '#!/bin/bash\nif [ ! -f "~/.elysiumroyale/elysium_royale.pid" ]; then /usr/local/bin/elysium_royaled -daemon ; fi' > /root/elysiumroyaleauto.sh
chmod -R 755 /root/elysiumroyaleauto.sh
#Setting auto start cron job for ROYAL
if ! crontab -l | grep "elysiumroyaleauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/elysiumroyaleauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"