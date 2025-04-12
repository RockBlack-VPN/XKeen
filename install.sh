opkg install tar
curl -s -L https://github.com/RockBlack-VPN/XKeen/releases/download/xkeen-v1.1.3.3/xkeen.tar --output xkeen.tar && tar -xvf xkeen.tar -C /opt/sbin --overwrite > /dev/null && rm xkeen.tar
xkeen -i
