#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Run the migration task
echo "Running migrate task..."
bundle exec rake migrate

# Run the Rake task
echo "Running seed task..."
bundle exec rake import_csv

# Run the Ruby application
echo "Running Ruby application..."
ruby app.rb
