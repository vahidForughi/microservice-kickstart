#!/bin/bash
set -e
set -u

add_a_user_and_database() {
  user=$1
  database=$2
  echo "Adding user '$user' and database '$database' ..."
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_PASSWORD" <<-EOSQL
      CREATE DATABASE $database;
      CREATE USER $user with encrypted password '$database';
      GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
}

echo "pg-init.sh running ..."
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
  for db in `echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '`; do
      add_a_user_and_database $db $db
  done
  echo "Multiple databases created"
fi
