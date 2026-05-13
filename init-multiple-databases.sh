#!/bin/bash

set -e
set -u

# Tạo các database
for db in identity_db paper_db trend_db user_db notification_db sync_db admin_db; do
	echo "Creating user and database '$db'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE DATABASE $db;
	    GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
EOSQL
done

echo "Databases created. Now executing init scripts..."

# Chạy các script tương ứng vào từng DB
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "identity_db" -f /docker-entrypoint-initdb.d/scripts/01_identity_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "paper_db" -f /docker-entrypoint-initdb.d/scripts/02_paper_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "trend_db" -f /docker-entrypoint-initdb.d/scripts/03_trend_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "user_db" -f /docker-entrypoint-initdb.d/scripts/04_user_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "notification_db" -f /docker-entrypoint-initdb.d/scripts/05_notification_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "sync_db" -f /docker-entrypoint-initdb.d/scripts/06_sync_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "admin_db" -f /docker-entrypoint-initdb.d/scripts/07_admin_service.sql

echo "Database initialization completed successfully!"
