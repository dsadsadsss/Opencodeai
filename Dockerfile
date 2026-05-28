FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    nginx \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download opencode2api
RUN wget -O /usr/local/bin/opencode2api \
    https://github.com/dsadsadsss/Opencodeai/releases/download/2/opencode2api-linux-amd64 \
    && chmod +x /usr/local/bin/opencode2api

# Download cloudflared
RUN wget -O /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

# Nginx config
RUN cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 3000;

    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
    }

    location / {
        default_type text/html;
        return 200 '<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>OpenCode API</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: #0f172a;
      color: #e2e8f0;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }
    .card {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 16px;
      padding: 48px 56px;
      text-align: center;
      box-shadow: 0 8px 40px rgba(0,0,0,0.4);
    }
    h1 { font-size: 2rem; color: #38bdf8; margin-bottom: 8px; }
    p  { color: #94a3b8; margin-bottom: 24px; }
    code {
      background: #0f172a;
      border: 1px solid #475569;
      border-radius: 6px;
      padding: 4px 10px;
      font-size: 0.95rem;
      color: #7dd3fc;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 OpenCode API</h1>
    <p>Service is running</p>
    <code>POST /api/v1/chat/completions</code>
  </div>
</body>
</html>';
    }
}
EOF

# Startup script
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
