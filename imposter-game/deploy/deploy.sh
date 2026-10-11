
#!/usr/bin/env bash
set -euo pipefail

HOST=""
KEY=""

while getopts "h:i:" opt; do
    case "$opt" in
        h) HOST="$OPTARG" ;;
        i) KEY="$OPTARG" ;;
        *) exit 1 ;;
    esac
done

if [ -z "$HOST" ] || [ -z "$KEY" ]; then
    echo "Usage: ./deploy/deploy.sh -h PUBLIC_IP -i KEY.pem"
    exit 1
fi

if [ ! -f "$KEY" ]; then
    echo "ERROR: SSH key not found: $KEY"
    exit 1
fi

for tool in ssh scp tar curl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Missing required tool: $tool"
        exit 1
    fi
done

cd "$(dirname "$0")/.."

echo "Running Rails tests..."
bundle exec rails test

echo "Packaging application..."
ARCHIVE="$(mktemp --suffix=.tar.gz)"
trap 'rm -f "$ARCHIVE"' EXIT

tar -czf "$ARCHIVE" \
    --exclude='.git' \
    --exclude='.env' \
    --exclude='.env.*' \
    --exclude='*.pem' \
    --exclude='log' \
    --exclude='tmp' \
    --exclude='storage' \
    --exclude='node_modules' \
    --exclude='vendor/bundle' \
    --exclude='config/master.key' \
    --exclude='config/credentials' \
    .

echo "Uploading application..."
scp -i "$KEY" "$ARCHIVE" "ubuntu@$HOST:/tmp/imposter-game.tar.gz"

echo "Deploying on EC2..."
ssh -i "$KEY" "ubuntu@$HOST" 'bash -s' <<'REMOTE'
set -euo pipefail

APP_DIR="/home/ubuntu/imposter-game"

mkdir -p "$APP_DIR"
tar -xzf /tmp/imposter-game.tar.gz -C "$APP_DIR"
rm -f /tmp/imposter-game.tar.gz

cd "$APP_DIR"

export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

eval "$(rbenv init - bash)"

# Load Rails production environment variables
set -a
source <(sudo cat /etc/imposter-game.env)
set +a

bundle install

RAILS_ENV=production bundle exec rails db:prepare
RAILS_ENV=production bundle exec rails assets:precompile

sudo systemctl restart imposter-game.service
REMOTE

echo "Checking health endpoint..."
curl --fail --retry 10 --retry-delay 3 \
    "http://$HOST/api/health"

echo
echo "Deployment complete!"
echo "Website: http://$HOST/"
