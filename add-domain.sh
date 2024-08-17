#!/bin/bash

# Check domain
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1

YOUR_EMAIL="your.email@gmail.com"

NGINX_SERVICE_NAME="your_nginx_service_name"
CERTBOT_SERVICE_NAME="your_certbot_service_name"

# your domain config path
CONFIG_PATH="./conf.d"
# your ssl path
SSL_PATH="./ssl"

# get nginx container id
TASK_ID=$(docker service ps --filter "desired-state=running" $NGINX_SERVICE_NAME -q | head -n 1)

NGINX_CONTAINER_ID=$(docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $TASK_ID)

# create new config file for this domain
cat > $CONFIG_PATH/${DOMAIN}.conf <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        root /var/www/certbot;
        index index.html;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
EOF

# check nginx config
docker exec $NGINX_CONTAINER_ID nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed 1."
    exit 1
fi

# restart nginx config
docker exec $NGINX_CONTAINER_ID nginx -s reload

CERT_BOT_TASK_ID=$(docker service ps --filter "desired-state=running" $CERTBOT_SERVICE_NAME -q | head -n 1)

CERT_BOT_CONTAINER_ID=$(docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $CERT_BOT_TASK_ID)

# Register ssl with certbot
docker exec $CERT_BOT_CONTAINER_ID certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $YOUR_EMAIL --agree-tos --no-eff-email --force-renewal

# create or update config Nginx for SSL
SSL_CONFIG_FILE="$CONFIG_PATH/${DOMAIN}.conf"
echo "Config file path: $SSL_CONFIG_FILE"

# check Existed ssl config
if grep -q 'ssl_certificate' "$SSL_CONFIG_FILE"; then
    echo "Existing SSL config found, updating..."
    # update
    sed -i "/ssl_certificate/c\    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;" "$SSL_CONFIG_FILE"
    sed -i "/ssl_certificate_key/c\    ssl_certificate_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;" "$SSL_CONFIG_FILE"
else
    echo "No existing SSL config found, adding new..."
    # add ssl config
    if ! grep -q 'listen 443 ssl;' "$SSL_CONFIG_FILE"; then
        echo "Adding listen directive for SSL."
        sed -i "/listen 80;/a \    listen 443 ssl;" "$SSL_CONFIG_FILE"
    fi
    sed -i "/listen 443 ssl;/a \    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;\n    ssl_certificate_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;" "$SSL_CONFIG_FILE"
fi

# test Nginx
echo "Testing Nginx configuration..."
docker exec $NGINX_CONTAINER_ID nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Check your configuration."
    exit 1
else
    echo "Nginx configuration test successful. Reloading Nginx..."
    docker exec $NGINX_CONTAINER_ID nginx -s reload
fi



