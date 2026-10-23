# Imposter Game

A party game built with Ruby on Rails and SQLite.

The planned game lets players share one device. Everyone sees a secret
word except one player—the imposter. Players give clues and then vote
on who they think the imposter is.

## Current Features

- Database models for categories, words, games, and players
- Three sample categories with five words each
- Automated tests
- Startup and EC2 deployment scripts

Gameplay and category editing are still in development.

## Run the App

On Ubuntu, run this from the project folder:

```bash
./start.sh
```

The script installs dependencies, prepares the database, loads sample
data, and starts the app.

On Windows with Ruby 4.0.4 and Bundler installed, run:

```bash
bundle install
bundle exec rails db:prepare db:seed
bundle exec rails server
```

Open http://localhost:3000.

## Run Tests

```bash
bundle exec rails db:migrate RAILS_ENV=test
bundle exec rails test RAILS_ENV=test
```

## Live Site

http://52.34.222.19/