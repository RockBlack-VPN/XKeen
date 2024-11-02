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



