FROM kong:3.9.1

USER root

RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /kong/declarative && chown -R kong:kong /kong/declarative

COPY kong/declarative/kong.yml.template /kong/declarative/kong.yml.template

ENV KONG_DATABASE="off"
ENV KONG_DECLARATIVE_CONFIG="/kong/declarative/kong.yml"
ENV KONG_PROXY_ACCESS_LOG="/dev/stdout"
ENV KONG_ADMIN_ACCESS_LOG="/dev/stdout"
ENV KONG_PROXY_ERROR_LOG="/dev/stderr"
ENV KONG_ADMIN_ERROR_LOG="/dev/stderr"
ENV KONG_ADMIN_LISTEN="0.0.0.0:8001"

RUN echo "#!/bin/bash" > /docker-entrypoint-custom.sh && \
    echo "envsubst < /kong/declarative/kong.yml.template > /kong/declarative/kong.yml" >> /docker-entrypoint-custom.sh && \
    echo "exec /docker-entrypoint.sh \"\$@\"" >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh

USER kong

ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["kong", "docker-start"]