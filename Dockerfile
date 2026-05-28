FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN wget -O /usr/local/bin/opencode2api \
    https://github.com/dsadsadsss/Opencodeai/releases/download/2/opencode2api-linux-amd64 \
    && chmod +x /usr/local/bin/opencode2api
RUN wget -O /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared
RUN cat > /start.sh << 'EOF'
#!/bin/bash
set -e
echo "[1/2] Starting opencode2api on :3000 ..."
/usr/local/bin/opencode2api --password "$PW" --port 3000 &
sleep 2
if [ -n "$TOKEN" ]; then
    echo "[2/2] Starting Cloudflare Tunnel ..."
    /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$TOKEN" &
else
    echo "[2/2] TOKEN not set, skipping Cloudflare Tunnel."
fi
wait
EOF
RUN chmod +x /start.sh
EXPOSE 3000
CMD ["/start.sh"]
