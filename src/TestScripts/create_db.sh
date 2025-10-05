#!/bin/bash
set -e

PGPASSWORD="password"
HOST="localhost"
USER="postgres"
DB="testdb"
PORT="5433"
SQL_FILE="Shared/db/init-scripts/create_db.sql"

psql -h "$HOST" -U "$USER" -d "$DB" -p "$PORT" -f "$SQL_FILE" > /dev/null 2>&1

