#!/bin/bash
set -euo pipefail

PORT=1389
URL="ldap://127.0.0.1:${PORT}"
WORKDIR="."
DBDIR="$WORKDIR/db"
PID=""

BINDDN="uid=alice,ou=people,dc=freeiam,dc=org"
BINDPW="i-am-just-alice"

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
    echo "Testing @objectClass ($mode)"
    echo

    mkdir -p "$DBDIR"
    rm -f "$DBDIR"/*

    slaptest -f "$config" -u

    slapadd -f "$config" -l initial.ldif

    slapd -f "$config" -h "$URL/" -d 256 > "$WORKDIR/slapd-$mode.log" 2>&1 &
    PID=$!

    sleep 1

    set +e
    ldapmodify -x -H "$URL" -D "$BINDDN" -w "$BINDPW" -f hacking_attempt.ldif
    local rc=$?

    ldapcompare -x -H "$URL" -D "cn=admin,dc=freeiam,dc=org" -w "iamfree" "uid=alice,ou=people,dc=freeiam,dc=org"  "objectClass:freeiamExampleAdminRole"
    local rc2=$?

    ldapmodify -x -H "$URL" -D "uid=john,ou=people,dc=freeiam,dc=org" -w "i-am-just-john" -f hacking_attempt2.ldif
    set -e

    echo
    echo "ldapadd exit code: $rc"
    echo "ldapcompare exit code: $rc2"

    if [ "$mode" = "vuln" ] && [ "$rc" -eq 0 ] && [ "$rc2" -eq 6 ]; then
        # modifying entry "uid=alice,ou=people,dc=freeiam,dc=org"
        # TRUE
        echo "RESULT: VULNERABLE - object class was added!"
    elif [ "$mode" = "safe" ] && [ "$rc" -eq 50 ] && [ "$rc2" -eq 5 ]; then
        # ldap_modify: Insufficient access (50)
        # FALSE
        echo "RESULT: expected reject"
    else
        echo "RESULT: UNEXPECTED!"
    fi

    echo
    echo "#######################"
    echo

    stop_slapd
}

run_test safe
run_test vuln
