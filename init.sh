#!/bin/bash

# This file copies the configuration files to destination folder

# Import .env variables
. .env

sudo mkdir -p                       ${BASE_DIR}
sudo chown -cR `whoami`:`whoami` -R ${BASE_DIR}
# sudo chmod 755 ${BASE_DIR}

# Copy nginx configuration file
mkdir -p ${BASE_DIR}/proxy/{certs,vhost,htmls,confd,dhparam}
cp -r ./nginx-proxy/config/proxy-settings.conf ${BASE_DIR}/proxy/confd/proxy-settings.conf

# Bitwarden

# Copy nginx configuration file
mkdir -p ${BASE_DIR}/bitwarden/{identity,nginx,web}
# Copy pfx certificate
cp -r ./bitwarden/identity/identity.pfx     ${BASE_DIR}/bitwarden/identity/identity.pfx

# Create app-id.json from template
export BW_HOST=${BW_HOST}
envsubst '${BW_HOST}' < ./bitwarden/web/app-id.json.tmpl > ${BASE_DIR}/bitwarden/web/app-id.json

# Create environment variables from template
# export BW_HOST=${BW_HOST}
export BW_ADMIN_EMAIL=${BW_ADMIN_EMAIL}
export SA_PASSWORD=${SA_PASSWORD}
envsubst < ./bitwarden/env/global.override.env.tmpl > ./bitwarden/env/global.override.env


# Self signed certificates ####################################
echo -n "Do you want to create self-signed certificate (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Initialize parameters
    DOMAIN="www.$BASE_DOMAIN"
    COMPANY="Home Inc."
    COUNTRY="DE"

    KEY_PATH=${BASE_DIR}/proxy/certs

    # Generate dhparam (will take a while)
    cp -r ./bitwarden/nginx/dhparam/ ${BASE_DIR}/proxy/
    # openssl dhparam -out ${BASE_DIR}/proxy/dhparam/dhparam.pem 4096
    ln "$BASE_DIR/proxy/dhparam/dhparam.pem" "$KEY_PATH/dhparam.pem"

    # Generate Keys for Bitwarden
    # Generate .key, .crt and .pem
    openssl req -x509 -newkey rsa:4096 -keyout "$KEY_PATH/$BASE_DOMAIN.key" -out "$KEY_PATH/$BASE_DOMAIN.crt" -days 365 -subj "/CN=$DOMAIN/O=$COMPANY/C=$COUNTRY" -nodes

    # Create (hard) links on domainFolder/fullchain.pem .. key
    mkdir -p $KEY_PATH/$BW_HOST
    ln "$KEY_PATH/$BASE_DOMAIN.crt" "$KEY_PATH/$BW_HOST/fullchain.pem"
    ln "$KEY_PATH/$BASE_DOMAIN.key" "$KEY_PATH/$BW_HOST/key.pem"

else
    echo "Please uncomment letsencrypt service inside docker-compose.yml to create TLS certificate via letsencrypt"
fi

echo "Initialization finished!"
echo "Please setup email for bitwarden under global.override.env before running 'docker-compose up -d' otherwise it will not work properly"