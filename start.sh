
#!/usr/bin/env bash
set -e

# Move to the project directory
cd "$(dirname "$0")"

echo "Checking required tools..."

# Check Ruby
if ! command -v ruby >/dev/null 2>&1; then
    echo "ERROR: Ruby is not installed."
    exit 1
fi

# Check Bundler
if ! command -v bundle >/dev/null 2>&1; then
    echo "ERROR: Bundler is not installed."
    exit 1
fi

# Check Ruby version
required_ruby=$(tr -d '[:space:]' < .ruby-version)
required_ruby="${required_ruby#ruby-}"
installed_ruby=$(ruby -e 'print RUBY_VERSION')

if [ "$required_ruby" != "$installed_ruby" ]; then
    echo "ERROR: Ruby $required_ruby is required."
    echo "Installed version: $installed_ruby"
    exit 1
fi

echo "Installing dependencies..."
bundle install

echo "Preparing database..."
bundle exec rails db:prepare

echo "Starting Imposter Game..."
echo "Open http://localhost:3000"

exec bundle exec rails server -b 0.0.0.0 -p 3000
