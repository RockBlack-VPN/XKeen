# Discord
Для маршрутизации discord через vless нужно подключиться к роутеру по SSH и прописать 
```
xkeen -ap 80,443,50000:50030
```
Затем добавить блок в 05_routing.json

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
Для маршрутизации игр от Supercell (Brawlstars, Squad Busters, Clash Royale, Hay Day, ...) через vless нужно подключиться к роутеру по SSH и прописать 
```
xkeen -ap 80,443,9339
```
Затем добавить блок в 05_routing.json

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
