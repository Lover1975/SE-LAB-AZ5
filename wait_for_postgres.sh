#!/bin/bash

set -e

host="$1"
port="$2"
shift 2
cmd="$@"

echo "Waiting for PostgreSQL at $host:$port..."

while ! nc -z "$host" "$port"; do
  sleep 1
done

echo "PostgreSQL is available - executing command"
# Run migrations and then start the server in the foreground
python manage.py migrate
echo "Migrations complete, starting server..."
exec python manage.py runserver 0.0.0.0:8000
