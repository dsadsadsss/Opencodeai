FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    nginx \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/opencode2api \
    https://github.com/dsadsadsss/Opencodeai/releases/download/2/opencode2api-linux-amd64 \
    && chmod +x /usr/local/bin/opencode2api

RUN wget -O /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

RUN cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 3000;
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
    }
}
EOF

RUN cat > /start.sh << 'EOF'
#!/bin/bash
set -e
echo "[1/3] Starting opencode2api on :8000 ..."
/usr/local/bin/opencode2api --password "$PW" &
echo "[2/3] Starting Nginx on :3000 ..."
nginx -g "daemon off;" &
sleep 2
if [ -n "$TOKEN" ]; then
    echo "[3/3] Starting Cloudflare Tunnel ..."
    /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$TOKEN" &
else
    echo "[3/3] TOKEN not set, skipping Cloudflare Tunnel."
fi
wait
EOF
RUN chmod +x /start.sh

EXPOSE 3000 8000
CMD ["/start.sh"]
