opkg install tar
curl -s -L https://github.com/RockBlack-VPN/XKeen/releases/latest/download/xkeen.tar --output xkeen.tar && tar -xvf xkeen.tar -C /opt/sbin --overwrite > /dev/null && rm xkeen.tar
xkeen -i
