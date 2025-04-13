# Установка OPKG Entware на роутер Keenetic
Скачайте для роутера необходимый пакет Entware

`4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Giant (KN-2610), Hero 4G (KN-2310/2311), Hopper (KN-3810) и Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II` используйте для установки архив **mipsel** — [mipsel-installer](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz)

`Ultra SE (KN-2510), Giga SE (KN-2410), DSL (KN-2010), Duo (KN-2110), Ultra SE (KN-2510),  Hopper DSL (KN-3610) и Zyxel Keenetic DSL, LTE, VOX` используйте для установки архив **mips** — [mips-installer](https://bin.entware.net/mipssf-k3.4/installer/mips-installer.tar.gz)

`Peak (KN-2710), Ultra (KN-1811), Giga (KN-1012), Hopper (KN-3811) и Hopper SE (KN-3812)` используйте для установки архив **aarch64** — [aarch64-installer](https://bin.entware.net/aarch64-k3.10/installer/aarch64-installer.tar.gz)

**Установите на роутер нужные компоненты OPKG**

```
Интерфейс USB
```
```
Файловая система Ext
```
```
Общий доступ к файлам и принтерам по протоколу SMB
```
```
Поддержка открытых пакетов
```
```
Прокси-сервер DNS-over-TLS
```
```
Прокси-сервер DNS-over-HTTPS
```
```
Протокол IPv6
```
```
Модули ядра подсистемы Netfilter
```

Перейти в раздел `Приоритеты подключений` > `Политики доступа в интернет`

Создать политику **XKeen**

Выбрать способ доступа к интернету **Отметить провайдера**

Переместить необходимые устройства из **Политики по умолчанию** в политику **XKeen**
# Установка Xkeen на роутер Keenetic
Подключаемся по SSH к роутеру 192.168.1.1 порт 22 или 222 если установлен компонент SSH сервер

Логин - `root`
Пароль - `keenetic`

**Обновляем Entware**
```
opkg update && opkg upgrade
```
**Устанавливаем Xkeen**

```
opkg install curl
```
```
curl -sOfL https://raw.githubusercontent.com/RockBlack-VPN/XKeen/main/install.sh
```
```
chmod +x ./install.sh
```
```
./install.sh
```


**Перенести сервисы Keenetic с 443 порта**

Данная команда вводится в CLI роутера
```
ip http ssl port 8443
```
Сохранить изменения
```
system configuration save
```

> [!TIP]
> `xkeen generator` - https://rockblack.pro/xkeen_generator.html
> 
> `MiniToolPartitionWizard 12.8` - [Скачать](https://rockblack.pro/soft/MiniToolPartitionWizard.zip)
>
>  `MobaXterm 24.1` - [Скачать](https://rockblack.pro/soft/MobaXterm.zip)
____

# Обновление ядра XRAY на роутере Keenetic
Перед обновлением Xray для обеспечения корректной работы XKeen необходимо удалить файл **02_transport.json** из директории **opkg\etc\xray\configs**. Обратите внимание, что в новой версии этот файл больше не используется, поэтому возвращать его не нужно. После этого добавьте в верхнюю часть файла **05_routing.json** следующую строку:
```
"domainStrategy": "IPIfNonMatch",
```

![Screenshot](https://rockblack.pro/images/xray/Screenshot_2.jpg)

![Screenshot](https://rockblack.pro/images/xray/Screenshot_1.jpg)

Выполните команду, чтобы скачать скрипт установки:
```
curl -s -S -L -O https://github.com/Corvus-Malus/XKeen-docs/raw/main/Installer/install_xray.sh
```
Сделайте скрипт исполняемым:
```
chmod +x install_xray.sh
```
Выполните скрипт с параметром install для обновления:
```
./install_xray.sh update
```

Для проверки версии ядра xray выполните команду:
```
xray -version
```
___________________________________________________________________


**Для восстановления оригинального файла xray (откат обновления)**

Выполните скрипт с параметром recover:
```
./install_xray.sh recover
```

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

**2-й способ**

Открыть порты xkeen
```
xkeen -ap 80,443,50000:50030
```

Добавить ip адреса в 05_routing.json
```
5.200.14.128/25
34.0.0.0/15
34.2.0.0/16
34.3.0.0/23
34.3.2.0/24
35.192.0.0/12
35.208.0.0/12
35.224.0.0/12
35.240.0.0/13
66.22.192.0/18
91.105.192.0/23
91.108.4.0/22
91.108.8.0/22
91.108.12.0/22
91.108.16.0/22
91.108.20.0/22
91.108.56.0/23
91.108.58.0/23
95.161.64.0/20
138.128.136.0/21
149.154.160.0/21
149.154.168.0/22
149.154.172.0/22
162.158.0.0/15
172.64.0.0/13
185.76.151.0/24
199.247.24.0/24
```

```
xkeen -restart
```

![Screenshot](https://rockblack.pro/images/xray/Screenshot_89.jpg)
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

# Приложение ChatGPT 
Если не работает приложение ChatGPT, то нужно заблокировать quic (udp 80/443) в firewall кинетика или в `routing.json`

```
{
        "network": "udp",
        "port": "443",
        "outboundTag": "block",
        "type": "field"               
      },
```
![Screenshot](https://rockblack.pro/images/xray/Screenshot_295.jpg)

Сделать перезагрузку
```
xkeen -restart
```
____
> [!TIP]
> [VPN на роутер](https://rockblack.pro/price) - WireGuard, AmneziaWG, OpenVPN, Vless, Outline, Socks5

> [Телеграмм бот](https://t.me/Cripto_Plusbot)

> [Телеграмм группа](https://t.me/rockblack_vpn)



