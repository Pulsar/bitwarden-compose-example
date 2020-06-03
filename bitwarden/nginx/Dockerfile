ARG nginx_version=1.16
FROM nginx:${nginx_version}

LABEL com.bitwarden.product="bitwarden"

# Add environment variables
ENV BW_GROUP="bitwarden"
ENV BW_USER="bitwarden"
ENV BW_USER_DIR=/home/bitwarden
ENV BW_GID=1000
ENV BW_UID=1000

# Add the user UID:1000, GID:1000, home at /app
RUN groupadd -o -r ${BW_GROUP}  -g ${BW_GID} && \
    useradd  -o -r -u ${BW_UID} -g ${BW_GROUP} -m -d ${BW_USER_DIR} -s /sbin/nologin -c "App user" ${BW_USER} && \
    chmod 755 ${BW_USER_DIR}

# Set the working directory to app home directory
WORKDIR ${BW_USER_DIR}

# Specify the user to execute all commands below
# USER ${BW_USER}


ENV BW_HOST     localhost
ENV BW_TLS_PATH /etc/certs

RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        gosu \
        curl \
    && rm -rf /var/lib/apt/lists/*

COPY ./config/             /etc/nginx/
COPY template/default.tmpl ${BW_USER_DIR}

COPY logrotate.sh  /
COPY entrypoint.sh /

EXPOSE 8080
EXPOSE 8443

RUN chmod +x /entrypoint.sh \
    && chmod +x /logrotate.sh

HEALTHCHECK CMD curl --insecure -Lfs https://localhost:8443/alive || curl -Lfs http://localhost:8080/alive || exit 1

CMD ["/entrypoint.sh"]
