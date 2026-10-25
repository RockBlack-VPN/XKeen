# XKeen на роутере Keenetic / Netcraze

Инструкция по установке и настройке **XKeen 2.x** — утилиты выборочной маршрутизации трафика через ядра **Xray** и **Mihomo**.

Актуальная версия XKeen развивается в репозитории [jameszeroX/XKeen](https://github.com/jameszeroX/XKeen). Основной порядок установки взят из официальной вики: [Порядок установки](https://github.com/jameszeroX/XKeen/wiki/Порядок-установки).

- [Подготовка роутера](#подготовка-роутера)
- [Установка Entware](#установка-opkg-entware-на-роутер-keenetic)
- [Подготовка KeeneticOS 5.2 (токен RCI)](#подготовка-роутера-c-keeneticos-52)
- [Установка XKeen](#установка-xkeen)
- [Настройка конфигурации](#настройка-конфигурации)
- [Обновление XKeen и ядер](#обновление-xkeen-и-ядер)
- [Полезные команды](#полезные-команды)
- [Нет подключения по SSH к Entware](#нет-подключения-по-ssh-к-entware)
- [Backup Entware + XKeen](#backup-entware--xkeen)
- [Маршрутизация приложений и игр](#маршрутизация-приложений-и-игр)

____

# Подготовка роутера

Для установки XKeen требуется:

- [роутер Keenetic / Netcraze](https://github.com/jameszeroX/XKeen/wiki/Routers-Info) с установленной средой **Entware** (лучше на внешний USB-накопитель);
- настроенные **шифрованные DNS** (DNS-over-TLS / DNS-over-HTTPS) — [инструкция](https://support.netcraze.ru/ultra/nc-1812/ru/31543.html).

**Установите на роутер компоненты** (Общие настройки → Изменить набор компонентов):

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

**Создайте политику доступа**

Перейдите в раздел `Приоритеты подключений` > `Политики доступа в интернет`

Создайте политику **XKeen**

Выберите способ доступа к интернету — **отметьте провайдера**

Переместите необходимые устройства из **Политики по умолчанию** в политику **XKeen**

> [!NOTE]
> Режим работы по умолчанию — **Hybrid** (TCP → Redirect, UDP → TProxy). Переносить 443 порт веб-интерфейса для него **не нужно**.
> Перенос 443 порта нужен только для режима чистого **TProxy** или при проксировании по [DSCP-метке 61](https://github.com/jameszeroX/XKeen/wiki/Маршрутизация-по-DSCP) с отдельным `tproxy` inbound — см. [ниже](#режим-tproxy-и-перенос-443-порта).

____

# Установка OPKG Entware на роутер Keenetic

Официальная инструкция: [Установка репозитория Entware](https://support.netcraze.ru/giga/nc-1012/ru/20980-installing-the-entware-repository-on-a-usb-drive.html)

Скачайте для роутера необходимый пакет Entware

`4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Giant (KN-2610), Hero 4G (KN-2310/2311), Hopper (KN-3810) и Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II` используйте архив **mipsel** — [mipsel-installer](https://bin.entware.net/mipselsf-k3.4/installer/mipsel-installer.tar.gz)

`Ultra SE (KN-2510), Giga SE (KN-2410), DSL (KN-2010), Duo (KN-2110), Hopper DSL (KN-3610) и Zyxel Keenetic DSL, LTE, VOX` используйте архив **mips** — [mips-installer](https://bin.entware.net/mipssf-k3.4/installer/mips-installer.tar.gz)

`Peak (KN-2710), Ultra (KN-1811), Ultra (NC-1812), Giga (KN-1012), Hopper (KN-3811) и Hopper SE (KN-3812)` используйте архив **aarch64** — [aarch64-installer](https://bin.entware.net/aarch64-k3.10/installer/aarch64-installer.tar.gz)

Подключитесь по SSH к Entware: `192.168.1.1`, порт `22` (или `222`, если установлен компонент «SSH-сервер»)

Логин — `root`, пароль — `keenetic` (смените его командой `passwd`)

____

# Подготовка роутера c KeeneticOS 5.2

> Для KeeneticOS до версии 5.2 этот этап можно пропустить и сразу перейти к [установке XKeen](#установка-xkeen).

В KeeneticOS 5.2 введены токены доступа к консольным RCI-запросам (политики, порты, версия прошивки и другие данные, нужные XKeen). Поддержка токенов появилась в **XKeen 2.1**.

1. В веб-интерфейсе роутера откройте раздел **«Пользователи и доступ»** и **добавьте токен**

   ![Получение токена этап 1](https://raw.githubusercontent.com/wiki/jameszeroX/XKeen/images/add_token.png)

2. **Скопируйте** полученный токен

   ![Получение токена этап 2](https://raw.githubusercontent.com/wiki/jameszeroX/XKeen/images/copy_token.png)

3. Создайте файл `/opt/etc/xkeen/xkeen.json` с токеном (минимально необходимый вариант):

   ```
   mkdir -p /opt/etc/xkeen
   cat > /opt/etc/xkeen/xkeen.json << 'EOF'
   {
     "xkeen": {
       "rci_token": "ВАШ_ТОКЕН"
     }
   }
   EOF
   ```

   Можно также взять [шаблон конфигурационного файла](https://github.com/jameszeroX/XKeen/releases/download/2.0.1_Beta/xkeen.json) и заполнить его по [инструкции](https://github.com/jameszeroX/XKeen/wiki/Конфигурационный-файл). Настройки из файла, созданного до установки (токен, `gh_proxy`, повторы загрузки), применяются уже на этапе установки.

После этого можно приступать к установке XKeen (поддерживается интерактивная установка и [автоустановка](https://github.com/jameszeroX/XKeen/wiki/autoinstall)).

____

# Установка XKeen

### Интерактивная установка

Выполните в SSH-консоли роутера:

```
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
sh -c "$(curl -sSL https://raw.githubusercontent.com/jameszeroX/XKeen/main/install.sh)"
```

либо через CDN jsDelivr:

```
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
sh -c "$(curl -sSL https://cdn.jsdelivr.net/gh/jameszeroX/XKeen@main/install.sh)"
```

либо через скрипт из этого репозитория (он загружает и запускает тот же официальный установщик, с резервными зеркалами):

```
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
curl -sSfLO https://raw.githubusercontent.com/RockBlack-VPN/XKeen/main/install.sh && sh ./install.sh
```

Архив актуальной стабильной версии также публикуется в [Releases](https://github.com/RockBlack-VPN/XKeen/releases/latest) этого репозитория.

Если установка не начинается из-за недоступности Entware (`bin.entware.net`), замените ссылку на рабочее зеркало и повторите команду:

```
sed -i 's,http://bin.entware.net/,http://mirrors.nju.edu.cn/entware/,g' /opt/etc/opkg.conf
```

**Ход установки:**

1. Выберите версию XKeen: **Stable** (рекомендуется), **Beta** или **Legacy**
2. Выберите ядро или ядра проксирования (**Xray** и/или **Mihomo**)
3. Выберите версии ядер из списка (или введите вручную в пункте `9`)
4. Для Xray выберите **GeoSite** (несколько — через пробел, все — пункт `1`)
5. Аналогично выберите **GeoIP**
6. Решите, нужно ли исключать из проксирования российские IP-подсети
7. При необходимости включите автообновление Geo-файлов и выберите день и время
8. Добавьте XKeen в автозагрузку

После завершения установки настройте конфигурационные файлы и запустите проксирование:

```
xkeen -start
```

### Автоматическая установка

Без вопросов, со значениями по умолчанию (Xray + Mihomo, все геобазы, cron, автозагрузка):

```
sh -c "$(curl -sSL https://raw.githubusercontent.com/jameszeroX/XKeen/main/install.sh)" -- --stable
```

Если XKeen уже установлен, полную установку без вопросов выполняет `xkeen -i auto`, например только с ядром Xray:

```
xkeen -i auto cores=xray
```

Подробнее — [Автоматическая установка XKeen](https://github.com/jameszeroX/XKeen/wiki/autoinstall).

____

# Настройка конфигурации

### Xray

При чистой установке XKeen создаёт шаблоны конфигурации в `/opt/etc/xray/configs/`. Редактировать нужно два файла:

- `04_outbounds.json` — настройки подключения к серверу
- `05_routing.json` — правила выборочной маршрутизации ([пример из этого репозитория](05_routing.json))

Остальные файлы в `/opt/etc/xray/configs/` рабочие и редактирования не требуют.

Проверить конфигурацию на ошибки:

```
xkeen -xtest
```

### Mihomo

Настройки ядра Mihomo находятся в одном файле `/opt/etc/mihomo/config.yaml` ([пример из этого репозитория](config.yaml), [базовый шаблон](https://github.com/zxc-rv/assets/blob/main/config_templates/mihomo/config.yaml)).

Проверить конфигурацию и переключиться между ядрами:

```
xkeen -mtest
xkeen -mihomo
xkeen -xray
```

### Режим TProxy и перенос 443 порта

По умолчанию XKeen работает в режиме **Hybrid**. Для перехода в режим чистого **TProxy** замените файл `/opt/etc/xray/configs/03_inbounds.json` на [03_inbounds.json для TProxy](https://github.com/jameszeroX/XKeen/releases/download/2.0.1_Beta/03_inbounds.json).

В режиме TProxy (а также для DSCP 61 с отдельным `tproxy` inbound) нужно освободить 443 порт веб-интерфейса: **«Пользователи и доступ»** → порт управления, либо в CLI роутера:

```
ip http ssl port 5443
```
```
system configuration save
```

Порт наружу не открывается — он нужен модулю `xt_TPROXY.ko`. После переноса ссылки доступа к роутеру из интернета получат порт, например `https://myrouter.netcraze.link:5443`. Подробнее — [Режимы работы XKeen](https://github.com/jameszeroX/XKeen/wiki/XKeen-modes).

> [!TIP]
>
> `Outbound generator` — https://zxc-rv.github.io/XKeen-UI/Outbound_Generator/
>
> `routing generator` — https://xray-routing-generator.netlify.app
>
> `XKeen UI` — https://github.com/zxc-rv/XKeen-UI

____

# Обновление XKeen и ядер

В XKeen 2.x обновление выполняется встроенными командами — сторонние скрипты и ручное удаление `02_transport.json` больше не нужны.

| Команда | Действие |
|---|---|
| `xkeen -uk` | Обновить XKeen (`xkeen -uk auto` — без вопросов) |
| `xkeen -ux` | Установить / обновить Xray с выбором версии (`xkeen -ux auto` — последняя) |
| `xkeen -um` | Установить / обновить Mihomo с выбором версии (`xkeen -um auto` — последняя) |
| `xkeen -ux v26.7.28` | Установить конкретную версию Xray (в том числе откат) |
| `xkeen -ug` | Обновить GeoFile / GeoIPSET |
| `xkeen -channel` | Переключить канал обновлений Stable / Beta |

Перед обновлением можно сделать резервные копии: `xkeen -kb` (XKeen), `xkeen -xb` (конфигурация Xray), `xkeen -mb` (конфигурация Mihomo). Восстановление — `-kbr`, `-xbr`, `-mbr`.

Проверить версию ядра Xray:

```
xray -version
```

> [!IMPORTANT]
> При переходе со старой версии XKeen 1.x удалите из `/opt/etc/xray/configs/` файл `02_transport.json` (если он остался) и убедитесь, что в начале `05_routing.json` указан `"domainStrategy": "IPIfNonMatch",`.

____

# Полезные команды

| Команда | Действие |
|---|---|
| `xkeen -start` / `-stop` / `-restart` | Запуск / остановка / перезапуск |
| `xkeen -status` | Статус работы |
| `xkeen -ap 80,443` | Добавить порты проксирования |
| `xkeen -dp 80` | Удалить порт проксирования |
| `xkeen -cp` | Список портов проксирования |
| `xkeen -auto` | Включить / отключить автозапуск |
| `xkeen -diag` | Полная диагностика (для отчёта о проблеме) |
| `xkeen -v` | Версия XKeen |
| `xkeen -h` | Справка по всем командам |

Полный список — [справочник флагов xkeen](https://github.com/jameszeroX/XKeen/blob/main/docs/commands.md).

____

# Нет подключения по SSH к Entware

Зайдите на роутер по Telnet — `192.168.1.1`

Логин — `admin` и ваш пароль от роутера (не путать с паролем от Entware)

Выполните команды:
```
exec sh
```
```
rm -f /opt/var/run/dropbear.pid
```
```
/opt/etc/init.d/S51dropbear restart
```

После этого подключайтесь по SSH к Entware

____

# Backup Entware + XKeen

Резервное копирование для быстрого развертывания на новом носителе или восстановления на текущем.

Это позволит в любой момент развернуть готовую конфигурацию без повторной установки Entware и других компонентов (для вашей архитектуры процессора).

Подключитесь к роутеру по SSH и выполните:
```
opkg install tar && tar czvf /opt/entware_backup.tar.gz --exclude="/opt/entware_backup.tar.gz" -C /opt .
```

Скопируйте архив `entware_backup.tar.gz` с накопителя в удобное место, например на рабочий стол.

Чтобы развернуть архив на новом накопителе (или восстановить на старом, предварительно отформатировав его), создайте в корне накопителя папку `install` и поместите в неё файл `entware_backup.tar.gz`.

Затем в OPKG (через веб-интерфейс роутера) выберите нужный накопитель. В поле сценария initrc оставьте прежний путь:
```
/opt/etc/init.d/rc.unslung
```
Нажмите «Сохранить» и подождите одну-две минуты — бэкап будет развернут со всеми настройками.

Встроенные резервные копии XKeen: `xkeen -kb`, `xkeen -xb`, `xkeen -mb`.

____

# Маршрутизация приложений и игр

Во всех примерах ниже `vless-reality` — тег вашего outbound из `04_outbounds.json`. Блоки добавляются в `rules` файла `05_routing.json` **перед** финальным правилом `direct`. После изменений выполните:

```
xkeen -restart
```

## Discord

Откройте порты:
```
xkeen -ap 80,443,19200:19400,50000:50030
```
Добавьте блок в `05_routing.json`:

```
      {
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "udp",
        "port": "19200-19400,50000-50030"
      },
```

**2-й способ** — по IP-адресам (геобаза ZKeenIP):

```
      {
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "ip": [
          "ext:geoip_zkeenip.dat:discord",
          "ext:geoip_zkeenip.dat:cloudflare",
          "ext:geoip_zkeenip.dat:google"
        ]
      },
```

## Supercell

Hay Day, Clash of Clans, Boom Beach, Clash Royale, Brawl Stars, Squad Busters:

```
xkeen -ap 80,443,9339
```

```
      {
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "tcp",
        "port": "9339"
      },
```

## Throne and Liberty

```
xkeen -ap 80,443,10000,11005
```

```
      {
        "inboundTag": ["redirect", "tproxy"],
        "outboundTag": "vless-reality",
        "type": "field",
        "network": "tcp",
        "port": "10000,11005"
      },
```

## Telegram

```
xkeen -ap 80,443,596:599,1400,5222
```

Готовое правило есть в [05_routing.json](05_routing.json) (IP-подсети Telegram + `ext:geoip_v2fly.dat:telegram`).

## Приложение ChatGPT

Если не работает приложение ChatGPT, заблокируйте QUIC (UDP 443) в межсетевом экране Keenetic или в `05_routing.json`:

```
      {
        "network": "udp",
        "port": "443",
        "outboundTag": "block",
        "type": "field"
      },
```

____

## Ссылки

- XKeen (актуальный форк) — https://github.com/jameszeroX/XKeen
- Вики XKeen — https://github.com/jameszeroX/XKeen/wiki
- FAQ — https://github.com/jameszeroX/XKeen/wiki/FAQ
- Xray-core — https://github.com/XTLS/Xray-core
- Mihomo — https://github.com/MetaCubeX/mihomo

> [Сайи](https://my.rockblack.tech)

> [Телеграм-группа](https://t.me/rockblack_vpn)
