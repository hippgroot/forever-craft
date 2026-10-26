#!/usr/bin/env bash

cd "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

minutes=${1:-5}
[[ $minutes =~ ^[0-9]+$ ]] || { echo "Usage: $0 [minutes]" >&2; exit 1; }

log() { printf '%s %s\n' "$(date '+%F %T')" "$*"; }
rcon() { bash ./console.sh "$@" > /dev/null; }
say() { rcon say "$@" || log "warning: could not send: $*"; }

if ! rcon list; then
    log "Server is not reachable over RCON - not restarting."
    exit 1
fi

log "Restart scheduled in $minutes minute(s)"
if (( minutes > 1 )); then
    say "Server restarting in $minutes minutes"
    sleep $(( (minutes - 1) * 60 ))
fi
if (( minutes >= 1 )); then
    say "Server restarting in 1 minute"
    sleep 50
fi
for i in 10 9 8 7 6 5 4 3 2 1; do
    say "Restarting in $i..."
    sleep 1
done

log "Stopping server"
rcon save-all flush
rcon stop

for _ in $(seq 60); do
    sleep 10
    if rcon list 2> /dev/null; then
        log "Server is back up"
        exit 0
    fi
done
log "Server did not come back within 10 minutes - check: docker compose logs forevercraft-server"
exit 1
