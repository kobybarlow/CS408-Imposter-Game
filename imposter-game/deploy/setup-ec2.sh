
#!/usr/bin/env bash
set -euo pipefail

APP_NAME="imposter-game"
APP_USER="ubuntu"
APP_DIR="/home/$APP_USER/$APP_NAME"
RUBY_VERSION="4.0.4"
SERVICE_NAME="$APP_NAME.service"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run this script with sudo."
    exit 1
fi

echo "Installing Ubuntu dependencies..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx git curl rsync build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libyaml-dev libffi-dev libsqlite3-dev \
    sqlite3 libgmp-dev libjemalloc-dev \
    pkg-config autoconf bison

echo "Creating application directory..."
mkdir -p "$APP_DIR"
chown "$APP_USER:$APP_USER" "$APP_DIR"

echo "Installing rbenv..."
sudo -H -u "$APP_USER" bash -c '
set -e
if [ ! -d "$HOME/.rbenv" ]; then
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
fi

mkdir -p "$HOME/.rbenv/plugins"

if [ ! -d "$HOME/.rbenv/plugins/ruby-build" ]; then
    git clone https://github.com/rbenv/ruby-build.git \
        "$HOME/.rbenv/plugins/ruby-build"
fi
'

echo "Installing Ruby $RUBY_VERSION..."
sudo -H -u "$APP_USER" env \
    PATH="/home/$APP_USER/.rbenv/bin:$PATH" \
    RBENV_ROOT="/home/$APP_USER/.rbenv" \
    bash -c '
        eval "$(rbenv init - bash)"
        RUBY_BUILD_MAKE_OPTS="-j1" rbenv install -s "$1"
        rbenv global "$1"
        gem install bundler --no-document
        rbenv rehash
    ' bash "$RUBY_VERSION"

echo "Configuring nginx..."
cat > "/etc/nginx/sites-available/$APP_NAME" <<'NGINX'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

ln -sfn \
    "/etc/nginx/sites-available/$APP_NAME" \
    "/etc/nginx/sites-enabled/$APP_NAME"

rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx

echo "Installing systemd service..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/$SERVICE_NAME" \
    "/etc/systemd/system/$SERVICE_NAME"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"

echo "EC2 setup complete."
echo "Next: deploy the Rails application."
