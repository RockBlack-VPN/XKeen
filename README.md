# Entware
`Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Hero 4G (KN-2310/KN-2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810)` используйте для установки архив mipsel — mipsel-installer.tar.gz

`Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610)` используйте для установки архив mips — mips-installer.tar.gz

`Peak (KN-2710), Ultra (KN-1811), Giga (KN-1012), Hopper (KN-3811) и Hopper SE (KN-3812)` используйте для установки архив aarch64 — aarch64-installer.tar.gz

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



