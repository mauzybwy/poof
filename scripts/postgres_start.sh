#!/usr/bin/env sh

if ! `pg_ctl status 2>/dev/null | grep "server is running" 1>/dev/null`; then
    echo 'starting postgresql'
    pg_ctl start \
        -l "$PGLOG" \
        -o "-c listen_addresses= -c unix_socket_directories=$PGDIR"
else
    echo 'postgresql is already running, use postgres_restart to restart it'
fi
echo "connect to postgres with 'psql -U $(whoami) -d postgres'"
