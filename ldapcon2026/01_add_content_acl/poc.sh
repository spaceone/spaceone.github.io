#!/bin/bash
set -euo pipefail

PORT=1389
URL="ldap://127.0.0.1:${PORT}"
WORKDIR="."
DBDIR="$WORKDIR/db"
PID=""

BINDDN="cn=server1,ou=servers,dc=freeiam,dc=org"
BINDPW="secret"

cleanup() {
    if [ -n "$PID" ]; then
        echo
        echo "Stopping slapd (PID $PID)..."
        kill "$PID" 2>/dev/null || true
        wait "$PID" 2>/dev/null || true
        PID=""
    fi
}
trap cleanup EXIT INT TERM

stop_slapd() {
    cleanup
    sleep 1
}

run_test() {
    local mode="$1"
    local config="$WORKDIR/slapd-$mode.conf"

    echo "#######################"
    echo "Testing add_content_acl $mode"
    echo

    mkdir -p "$DBDIR"
    rm -f "$DBDIR"/*

    sed "s/^add_content_acl.*/add_content_acl ${mode}/g" "$WORKDIR/slapd.conf" > "$config"

    slaptest -f "$config" -u

    slapadd -f "$config" -l initial.ldif

    slapd -f "$config" -h "$URL/" -d 256 > "$WORKDIR/slapd-$mode.log" 2>&1 &
    PID=$!

    sleep 1

    set +e
    ldapadd -x -H "$URL" -D "$BINDDN" -w "$BINDPW" -f hacking_attempt.ldif
    local rc=$?
    set -e

    echo
    echo "ldapadd exit code: $rc"

    if [ "$mode" = "off" ] && [ "$rc" -eq 0 ]; then
        # adding new entry "uid=alice,ou=managed,dc=freeiam,dc=org"
        echo "RESULT: VULNERABLE - unauthorized entry created!"
    elif [ "$mode" = "on" ] && [ "$rc" -eq 50 ]; then
        # ldap_add: Insufficient access (50)
        # additional info: no write access to attribute
        echo "RESULT: expected reject"
    else
        echo "RESULT: UNEXPECTED!"
    fi

    echo
    echo "#######################"
    echo

    stop_slapd
}

run_test on
run_test off
