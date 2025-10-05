#!/bin/bash
set -e

PGPASSWORD="password" psql -h localhost -U postgres -d testdb -p 5433 -f Shared/db/clean-scripts/clean_db.sql > /dev/null 2>&1
