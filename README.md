# Discord
Для маршрутизации discord через vless нужно добавить блок в 05_routing.json

```
{
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "udp",
        "port": "50000-50030"
      },
```
Сделать перезагрузку
```
xkeen -restart
```
