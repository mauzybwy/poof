#!/usr/bin/env sh

if ! `pg_ctl status 2>/dev/null | grep "server is running" 1>/dev/null`; then
    echo 'starting postgresql'
    pg_ctl start \
        -l "$PGLOG" \
        -o "-c listen_addresses=localhost -c unix_socket_directories=$PGDIR"
    psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'poof_dev'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE poof_dev"
else
    echo 'postgresql is already running, use postgres_restart to restart it'
fi
echo "connect to postgres with 'psql -U postgres -d postgres'"
