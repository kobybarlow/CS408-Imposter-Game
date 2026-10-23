#!/usr/bin/env bash
set -euo pipefail

# Always run from the project root
cd "$(dirname "$0")"

REQUIRED_RUBY=$(tr -d '[:space:]' < .ruby-version)
REQUIRED_RUBY="${REQUIRED_RUBY#ruby-}"

echo "Starting Imposter Game setup..."

# Detect Ubuntu/Linux
if [[ "$(uname -s)" == "Linux" ]]; then

    # Install system dependencies on Ubuntu if needed
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "ERROR: Automatic Linux setup requires Ubuntu/Debian."
        exit 1
    fi

    echo "Checking Linux dependencies..."

    packages=(
        git curl build-essential
        libssl-dev libreadline-dev zlib1g-dev
        libyaml-dev libffi-dev libsqlite3-dev
        libgmp-dev pkg-config autoconf bison
    )

    missing_packages=()

    for package in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
            grep -q "install ok installed"; then
            missing_packages+=("$package")
        fi
    done

    if [ "${#missing_packages[@]}" -gt 0 ]; then
        echo "Installing missing Linux packages..."
        sudo apt-get update
        sudo apt-get install -y "${missing_packages[@]}"
    fi

    # Install rbenv if missing
    export RBENV_ROOT="$HOME/.rbenv"
    export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

    if [ ! -d "$RBENV_ROOT" ]; then
        echo "Installing rbenv..."
        git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
    fi

    mkdir -p "$RBENV_ROOT/plugins"

    if [ ! -d "$RBENV_ROOT/plugins/ruby-build" ]; then
        echo "Installing ruby-build..."
        git clone https://github.com/rbenv/ruby-build.git \
            "$RBENV_ROOT/plugins/ruby-build"
    fi

    eval "$(rbenv init - bash)"

    # Install the required Ruby version if missing
    if ! rbenv versions --bare | grep -Fxq "$REQUIRED_RUBY"; then
        echo "Installing Ruby $REQUIRED_RUBY..."
        RUBY_BUILD_MAKE_OPTS="-j1" rbenv install "$REQUIRED_RUBY"
    fi

    rbenv local "$REQUIRED_RUBY"

    # Install Bundler if missing
    if ! command -v bundle >/dev/null 2>&1; then
        echo "Installing Bundler..."
        gem install bundler --no-document
        rbenv rehash
    fi
fi

# Verify Ruby
if ! command -v ruby >/dev/null 2>&1; then
    echo "ERROR: Ruby is not installed."
    echo "On Windows, install Ruby $REQUIRED_RUBY before running this script."
    exit 1
fi

INSTALLED_RUBY=$(ruby -e 'print RUBY_VERSION')

if [ "$INSTALLED_RUBY" != "$REQUIRED_RUBY" ]; then
    echo "ERROR: Ruby $REQUIRED_RUBY is required."
    echo "Installed version: $INSTALLED_RUBY"
    exit 1
fi

# Verify Bundler
if ! command -v bundle >/dev/null 2>&1; then
    echo "ERROR: Bundler is not installed."
    exit 1
fi

echo "Installing Rails dependencies..."
bundle install

echo "Preparing database..."
bundle exec rails db:prepare

echo "Loading sample categories and words..."
bundle exec rails db:seed

echo "Starting Imposter Game..."
echo "Open http://127.0.0.1:3000"

exec bundle exec rails server -b 0.0.0.0 -p 3000