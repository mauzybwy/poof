#!/usr/bin/env sh

export PGDIR=$(pwd)/.postgres
export PGHOST=$PGDIR
export PGDATA=$PGDIR/data
export PGLOG=$PGDIR/log
export DATABASE_URL="postgresql:///postgres?host=$PGDIR"

if test ! -d "$PGDIR"; then
    mkdir "$PGDIR"
fi

if [ ! -d "$PGDATA" ]; then
    echo 'Initializing postgresql database...'
    initdb -U postgres "$PGDATA" --auth=trust >/dev/null
fi
