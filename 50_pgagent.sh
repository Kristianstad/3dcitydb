#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Load PGAGENT into $POSTGRES_DB
echo "Loading POINTCLOUD extensions into $DB"
"${psql[@]}" --dbname="$POSTGRES_DB" <<-'EOSQL'
	CREATE EXTENSION pgagent;
EOSQL
