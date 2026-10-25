#!/bin/sh
#
# Установщик XKeen для роутеров Keenetic / Netcraze.
#
# Скрипт загружает и запускает актуальный официальный установщик XKeen
# из репозитория jameszeroX/XKeen (XKeen 2.x с поддержкой KeeneticOS 5.2).
# Порядок установки: https://github.com/jameszeroX/XKeen/wiki/Порядок-установки
#
# Все параметры передаются официальному установщику без изменений:
#   ./install.sh              интерактивный выбор версии
#   ./install.sh --stable     стабильная версия
#   ./install.sh --beta       бета-версия
#   ./install.sh --legacy 1.1.3.9
#   ./install.sh --help

upstream_path="jameszeroX/XKeen"
installer="/tmp/xkeen-install.$$.sh"

trap 'rm -f "$installer"' EXIT INT TERM

if ! command -v curl >/dev/null 2>&1; then
    echo "Ошибка: не найден curl. Выполните: opkg update && opkg install curl tar"
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "Ошибка: не найден tar. Выполните: opkg update && opkg install curl tar"
    exit 1
fi

download() {
    curl -fsSL --connect-timeout 10 -m 60 -o "$installer" "$1" && [ -s "$installer" ]
}

raw_url="https://raw.githubusercontent.com/${upstream_path}/main/install.sh"
cdn_url="https://cdn.jsdelivr.net/gh/${upstream_path}@main/install.sh"

if ! download "$raw_url" && \
   ! download "$cdn_url" && \
   ! download "https://gh-proxy.com/$raw_url" && \
   ! download "https://ghfast.top/$raw_url"; then
    echo "Ошибка: не удалось загрузить установщик XKeen"
    echo "Проверьте доступ к GitHub и jsDelivr, затем повторите попытку"
    exit 1
fi

# Установщик скачивает xkeen.tar.gz в текущую директорию,
# поэтому, как и в официальной инструкции, работаем из /tmp
cd /tmp || exit 1

sh "$installer" "$@"
status=$?
rm -f "$installer"
exit $status
