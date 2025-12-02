#!/bin/bash

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}       NGINX + XRAY MANAGER (Install & Config)      ${NC}"
echo -e "${GREEN}====================================================${NC}"

# 1. ПРОВЕРКА ROOT
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Запустите скрипт от имени root!${NC}"
  exit 1
fi

# ==========================================================
# ГЛАВНОЕ МЕНЮ
# ==========================================================
echo ""
echo -e "${YELLOW}Что вы хотите сделать?${NC}"
echo "1) Полная установка с нуля (Nginx + SSL + Конфиг)"
echo "2) Добавить новый маршрут (Location) в существующий конфиг"
read -p "Ваш выбор (1 или 2): " MAIN_ACTION

# ==========================================================
# ФУНКЦИЯ ГЕНЕРАЦИИ БЛОКА LOCATION
# ==========================================================
generate_location_block() {
    local trans_type=$1
    local path_name=$2
    local target=$3 # IP:PORT или DOMAIN:PORT
    local is_local=$4 # "true" если шлем на 127.0.0.1, "false" если наружу (SSL)

    local block=""

    # === gRPC ===
    if [ "$trans_type" == "1" ]; then
        block="\n    # --- gRPC ($path_name) ---\n    location $path_name {\n        if (\$content_type !~ \"application/grpc\") { return 404; }\n        client_max_body_size 0;\n        grpc_socket_keepalive on;\n        grpc_read_timeout 1h;\n        grpc_send_timeout 1h;\n"
        
        if [ "$is_local" == "true" ]; then
            # Локально (Backend) - без SSL
            block+="        grpc_pass grpc://$target;\n"
        else
            # Наружу (Relay) - c SSL
            # Извлекаем домен из target (удаляем порт для ssl_name)
            local domain_only=$(echo $target | cut -d: -f1)
            block+="        grpc_pass grpcs://$target;\n        grpc_ssl_server_name on;\n        grpc_ssl_name $domain_only;\n"
        fi
        block+="    }"

    # === WebSocket ===
    elif [ "$trans_type" == "2" ]; then
        block="\n    # --- WebSocket ($path_name) ---\n    location $path_name {\n        if (\$http_upgrade != \"websocket\") { return 404; }\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade \$http_upgrade;\n        proxy_set_header Connection \"upgrade\";\n        proxy_buffering off;\n        proxy_read_timeout 1h;\n        proxy_send_timeout 1h;\n"

        if [ "$is_local" == "true" ]; then
            block+="        proxy_pass http://$target;\n        proxy_set_header X-Real-IP \$remote_addr;\n        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n        proxy_set_header Host \$host;\n"
        else
            local domain_only=$(echo $target | cut -d: -f1)
            block+="        proxy_pass https://$target;\n        proxy_ssl_server_name on;\n        proxy_ssl_name $domain_only;\n        proxy_set_header Host $domain_only;\n"
        fi
        block+="    }"

    # === XHTTP ===
    elif [ "$trans_type" == "3" ]; then
        block="\n    # --- SplitHTTP ($path_name) ---\n    location $path_name {\n        client_max_body_size 0;\n        proxy_buffering off;\n        proxy_request_buffering off;\n        proxy_http_version 1.1;\n        proxy_set_header Connection \"\";\n        keepalive_timeout 1h;\n"

        if [ "$is_local" == "true" ]; then
            block+="        proxy_pass http://$target;\n        proxy_set_header X-Real-IP \$remote_addr;\n        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n        proxy_set_header Host \$host;\n"
        else
            local domain_only=$(echo $target | cut -d: -f1)
            block+="        proxy_pass https://$target;\n        proxy_ssl_server_name on;\n        proxy_ssl_name $domain_only;\n        proxy_set_header Host $domain_only;\n"
        fi
        block+="    }"
    fi

    echo "$block"
}


# ==========================================================
# ВЕТКА 2: ДОБАВЛЕНИЕ LOCATION (БЫСТРАЯ)
# ==========================================================
if [ "$MAIN_ACTION" == "2" ]; then
    echo ""
    echo -e "${GREEN}Введите домен ЭТОГО сервера (чей конфиг правим):${NC}"
    read -p "-> " CURRENT_DOMAIN
    
    CONF_FILE="/etc/nginx/sites-available/$CURRENT_DOMAIN.conf"
    
    if [ ! -f "$CONF_FILE" ]; then
        echo -e "${RED}Ошибка: Конфиг файл $CONF_FILE не найден!${NC}"
        exit 1
    fi

    echo -e "${GREEN}--- Настройка нового маршрута ---${NC}"
    echo "1) gRPC"
    echo "2) WebSocket (WS)"
    echo "3) XHTTP / SplitHTTP"
    read -p "Выберите транспорт: " TRANSPORT_TYPE

    echo -e "Введите путь (например ${BLUE}/grpc-new${NC}):"
    read -p "-> " PATH_NAME

    echo ""
    echo -e "${YELLOW}Куда пересылать трафик этого маршрута?${NC}"
    echo "1) На другой сервер (Relay -> Внешний IP/Domain)"
    echo "2) В локальную панель 3XUI (Backend -> 127.0.0.1)"
    read -p "Выбор: " DEST_TYPE

    TARGET=""
    IS_LOCAL=""

    if [ "$DEST_TYPE" == "1" ]; then
        echo -e "Введите адрес внешнего сервера (например ${BLUE}de.tunnel.ru${NC}):"
        read -p "-> " REMOTE_HOST
        # Для gRPC важно добавить порт, если не указан, добавим 443
        if [[ "$TRANSPORT_TYPE" == "1" && "$REMOTE_HOST" != *":"* ]]; then
             TARGET="$REMOTE_HOST:443"
        else
             TARGET="$REMOTE_HOST"
        fi
        IS_LOCAL="false"
    else
        echo -e "Введите ЛОКАЛЬНЫЙ порт Inbound (например ${BLUE}2055${NC}):"
        read -p "-> " L_PORT
        TARGET="127.0.0.1:$L_PORT"
        IS_LOCAL="true"
    fi

    # Генерируем блок
    NEW_BLOCK=$(generate_location_block "$TRANSPORT_TYPE" "$PATH_NAME" "$TARGET" "$IS_LOCAL")

    # Вставляем в конфиг (удаляем последнюю скобку, пишем блок, возвращаем скобку)
    # Используем временный файл для безопасности
    head -n -1 "$CONF_FILE" > "${CONF_FILE}.tmp"
    echo -e "$NEW_BLOCK" >> "${CONF_FILE}.tmp"
    echo "}" >> "${CONF_FILE}.tmp"
    
    mv "${CONF_FILE}.tmp" "$CONF_FILE"

    echo -e "${BLUE}[INFO] Проверка и перезагрузка Nginx...${NC}"
    nginx -t
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        echo -e "${GREEN}УСПЕШНО! Маршрут добавлен.${NC}"
    else
        echo -e "${RED}Ошибка в конфиге! Откат изменений...${NC}"
        # Тут можно бы добавить бэкап, но пока просто предупредим
    fi
    exit 0
fi


# ==========================================================
# ВЕТКА 1: ПОЛНАЯ УСТАНОВКА
# ==========================================================

# 1. УСТАНОВКА ПАКЕТОВ
echo -e "${BLUE}[INFO] Установка Nginx и Certbot...${NC}"
apt-get update -qq
apt-get install -y nginx curl certbot -qq

# 2. ВВОД ДОМЕНА
echo ""
echo -e "${GREEN}Введите домен ЭТОГО сервера (например: rus.tunnel.ru):${NC}"
read -p "-> " CURRENT_DOMAIN
if [ -z "$CURRENT_DOMAIN" ]; then echo -e "${RED}Домен обязателен!${NC}"; exit 1; fi

# 3. SSL
echo ""
echo -e "${YELLOW}Откуда берем SSL сертификаты?${NC}"
echo "1) Сгенерировать НОВЫЕ бесплатно (Let's Encrypt)"
echo "2) У меня уже есть файлы (в папке /root/cert/...)"
read -p "Ваш выбор: " CERT_MODE

FINAL_CRT=""
FINAL_KEY=""

if [ "$CERT_MODE" == "1" ]; then
    systemctl stop nginx
    echo -e "${BLUE}[INFO] Генерация SSL...${NC}"
    certbot certonly --standalone -d "$CURRENT_DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email
    if [ $? -eq 0 ]; then
        FINAL_CRT="/etc/letsencrypt/live/$CURRENT_DOMAIN/fullchain.pem"
        FINAL_KEY="/etc/letsencrypt/live/$CURRENT_DOMAIN/privkey.pem"
    else
        echo -e "${RED}Ошибка получения SSL!${NC}"; exit 1
    fi
else
    CERT_SRC="/root/cert/$CURRENT_DOMAIN"
    CERT_DEST="/etc/nginx/ssl/$CURRENT_DOMAIN"
    if [ ! -f "$CERT_SRC/fullchain.pem" ]; then echo -e "${RED}Файлы не найдены!${NC}"; exit 1; fi
    mkdir -p "$CERT_DEST"
    cp "$CERT_SRC/fullchain.pem" "$CERT_DEST/fullchain.pem"
    cp "$CERT_SRC/privkey.pem" "$CERT_DEST/privkey.pem"
    chmod -R 755 "$CERT_DEST"
    FINAL_CRT="$CERT_DEST/fullchain.pem"
    FINAL_KEY="$CERT_DEST/privkey.pem"
fi

# 4. ЗАГЛУШКА
mkdir -p /var/www/html
echo "<h1>System Operational</h1>" > /var/www/html/index.html
chown -R www-data:www-data /var/www/html

# 5. ВЫБОР РОЛИ (ПЕРЕИМЕНОВАНО)
echo ""
echo -e "${GREEN}Выберите режим работы сервера:${NC}"
echo "1) Только проксирующий без 3XUI (RELAY -> Шлет на другой сервер)"
echo "2) Проксирующий под 3XUI (BACKEND -> Принимает на 127.0.0.1)"
read -p "Ваш выбор (1 или 2): " SERVER_ROLE

DEFAULT_TARGET_HOST=""
if [ "$SERVER_ROLE" == "1" ]; then
    echo -e "Введите домен ЦЕЛЕВОГО сервера (куда слать трафик):"
    read -p "-> " DEFAULT_TARGET_HOST
fi

# 6. СБОРКА ЛОКАЦИЙ
LOCATIONS_CONF=""
while true; do
    echo ""
    echo -e "${GREEN}--- Добавление маршрута ---${NC}"
    echo "1) gRPC"
    echo "2) WebSocket (WS)"
    echo "3) XHTTP / SplitHTTP"
    echo "0) ДАЛЕЕ (Создать конфиг)"
    read -p "Выбор: " T_TYPE
    if [ "$T_TYPE" == "0" ]; then break; fi

    read -p "Путь (например /secret): " P_NAME

    TARGET=""
    IS_LOCAL=""

    if [ "$SERVER_ROLE" == "1" ]; then
        # Relay
        TARGET="$DEFAULT_TARGET_HOST"
        # Для gRPC добавляем порт 443 если его нет
        if [[ "$T_TYPE" == "1" && "$TARGET" != *":"* ]]; then TARGET="$TARGET:443"; fi
        IS_LOCAL="false"
    else
        # Backend
        read -p "Локальный порт Inbound (например 2053): " L_PORT
        TARGET="127.0.0.1:$L_PORT"
        IS_LOCAL="true"
    fi

    BLOCK=$(generate_location_block "$T_TYPE" "$P_NAME" "$TARGET" "$IS_LOCAL")
    LOCATIONS_CONF+="$BLOCK"
    echo -e "${GREEN}Добавлено!${NC}"
done

# 7. ЗАПИСЬ КОНФИГА
CONF_FILE="/etc/nginx/sites-available/$CURRENT_DOMAIN.conf"
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

cat <<EOF > "$CONF_FILE"
server {
    listen 80;
    server_name $CURRENT_DOMAIN;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name $CURRENT_DOMAIN;
    ssl_certificate $FINAL_CRT;
    ssl_certificate_key $FINAL_KEY;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    keepalive_timeout 1h;
    client_body_timeout 1h;
    client_max_body_size 0;
    root /var/www/html;
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
$LOCATIONS_CONF
}
EOF

ln -sf "$CONF_FILE" "/etc/nginx/sites-enabled/$CURRENT_DOMAIN.conf"

echo -e "${BLUE}[INFO] Перезагрузка Nginx...${NC}"
nginx -t
if [ $? -eq 0 ]; then
    systemctl restart nginx
    echo -e "${GREEN}УСПЕШНО!${NC}"
else
    echo -e "${RED}ОШИБКА КОНФИГУРАЦИИ!${NC}"
fi