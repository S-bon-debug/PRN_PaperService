#!/bin/bash

set -e
set -u

# Tạo các database cho 5 services
for db in auth_db document_db storage_db aichat_db admin_db; do
	echo "Creating user and database '$db'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE DATABASE $db;
	    GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
EOSQL
done

echo "Databases created. Now executing init scripts..."

# Chạy các script tương ứng vào từng DB
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "auth_db" -f /docker-entrypoint-initdb.d/scripts/01_auth_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "document_db" -f /docker-entrypoint-initdb.d/scripts/02_document_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "storage_db" -f /docker-entrypoint-initdb.d/scripts/03_storage_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "aichat_db" -f /docker-entrypoint-initdb.d/scripts/04_aichat_service.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "admin_db" -f /docker-entrypoint-initdb.d/scripts/05_admin_service.sql

echo "Database initialization completed successfully!"
