# Установка OPKG Entware на роутер Keenetic
`4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Giant (KN-2610), Hero 4G (KN-2310/2311), Hopper (KN-3810) и Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II` используйте для установки архив mipsel — [mipsel-installer](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz)

`Ultra SE (KN-2510), Giga SE (KN-2410), DSL (KN-2010), Duo (KN-2110), Ultra SE (KN-2510),  Hopper DSL (KN-3610) и Zyxel Keenetic DSL, LTE, VOX` используйте для установки архив mips — [mips-installer](https://bin.entware.net/mipssf-k3.4/installer/mips-installer.tar.gz)

`Peak (KN-2710), Ultra (KN-1811), Giga (KN-1012), Hopper (KN-3811) и Hopper SE (KN-3812)` используйте для установки архив aarch64 — [aarch64-installer](https://bin.entware.net/aarch64-k3.10/installer/aarch64-installer.tar.gz)

# Установка Xkeen на роутер Keenetic
Оновляем Entware
`opkg update` и `opkg upgrade`, затем устанавливаем Xkeen

```
opkg install curl
```
```
curl -sOfL https://github.com/RockBlack-VPN/XKeen/blob/main/install.sh
```
```
chmod +x ./install.sh
```
```
./install.sh
```
____


# Discord
Для маршрутизации discord через vless нужно подключиться к роутеру по SSH и прописать 
```
xkeen -ap 80,443,50000:50030
```
Затем добавить блок в `05_routing.json`

```
{
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "udp",
        "port": "50000-50030"
      },
```

![Screenshot](https://rockblack.pro/images/xray/Screenshot_270.jpg)


Сделать перезагрузку
```
xkeen -restart
```

____


# Supercell
Для маршрутизации игр от Supercell (Hay Day, Clash of Clans, Boom Beach, Clash Royale, Brawl Stars, Squad Busters) через vless нужно подключиться к роутеру по SSH и прописать 
```
xkeen -ap 80,443,9339
```
Затем добавить блок в `05_routing.json`

```
{
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "tcp",
        "port": "9339"
      },

```

![Screenshot](https://rockblack.pro/images/xray/Screenshot_271.jpg)


Сделать перезагрузку
```
xkeen -restart
```
____

# Throne and Liberty

Для маршрутизации игры Throne and Liberty через vless нужно подключиться к роутеру по SSH и прописать 
```
xkeen -ap 80,443,10000,11005
```
Затем добавить блок в `05_routing.json`

```
{
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "tcp",
        "port": "10000,11005"
      },

```

![Screenshot](https://rockblack.pro/images/xray/Screenshot_272.jpg)


Сделать перезагрузку
```
xkeen -restart
```
____
> [!TIP]
> [VPN на роутер](https://rockblack.pro/price) - WireGuard, AmneziaWG, OpenVPN, Vless, Outline, Socks5

> [Телеграмм бот](https://t.me/Cripto_Plusbot)

> [Телеграмм группа](https://t.me/rockblack_vpn)



