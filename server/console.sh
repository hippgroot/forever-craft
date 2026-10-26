#!/usr/bin/env bash

cd "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

if [[ -t 1 ]]; then red=$'\e[31m' green=$'\e[32m' reset=$'\e[0m'; else red='' green='' reset=''; fi

err() { printf '%s\n' "${red}$*${reset}" >&2; }
die() { err "$@"; exit 1; }

trim() {
    local s=$2
    s=${s#"${s%%[![:space:]]*}"}
    s=${s%"${s##*[![:space:]]}"}
    printf -v "$1" '%s' "$s"
}

byte_length() { local LC_ALL=C; printf '%s' "${#1}"; }

[[ -f server.properties ]] || die "server.properties not found in $PWD"
port='' password='' key=''
while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    [[ $line == *=* ]] || continue
    trim key "${line%%=*}"
    case $key in
        rcon.port)     trim port     "${line#*=}" ;;
        rcon.password) trim password "${line#*=}" ;;
    esac
done < server.properties
[[ $port =~ ^[0-9]+$ && -n $password ]] ||
    die "rcon.port / rcon.password not set - enable-rcon=true is needed in server.properties"

host=${RCON_HOST:-localhost}
exec 3<>"/dev/tcp/$host/$port" || die "Could not connect to $host:$port - is the server running?"
req_id=0

pkt_file=$(mktemp) || exit 1
trap 'rm -f "$pkt_file"' EXIT

le32() {
    local n=$(( $1 & 0xFFFFFFFF ))
    printf "$(printf '\\%03o' $(( n & 0xFF )) $(( (n >> 8) & 0xFF )) $(( (n >> 16) & 0xFF )) $(( (n >> 24) & 0xFF )))"
}

le32_from_hex() {
    local h=$1 n
    n=$(( 0x${h:6:2}${h:4:2}${h:2:2}${h:0:2} ))
    (( n > 0x7FFFFFFF )) && n=$(( n - 0x100000000 ))
    printf '%s' "$n"
}

send_packet() {
    local type=$1 body=$2
    req_id=$(( req_id + 1 ))
    {
        le32 $(( 10 + $(byte_length "$body") ))
        le32 "$req_id"
        le32 "$type"
        printf '%s\000\000' "$body"
    } > "$pkt_file"
    cat "$pkt_file" >&3
}

read_exact() {
    local n=$1 hex
    hex=$(dd bs=1 count="$n" <&3 2>/dev/null | od -A n -t x1 -v | tr -d ' \n')
    [[ ${#hex} -eq $(( n * 2 )) ]] || { err "Connection closed by server"; return 1; }
    printf '%s' "$hex"
}

read_packet() {
    local hex len
    hex=$(read_exact 12) || return 1
    len=$(le32_from_hex "${hex:0:8}")
    pkt_id=$(le32_from_hex "${hex:8:8}")
    (( len >= 10 )) || { err "Malformed packet from server"; return 1; }
    pkt_body=$(dd bs=1 count=$(( len - 10 )) <&3 2>/dev/null; printf x)
    pkt_body=${pkt_body%x}
    [[ $(byte_length "$pkt_body") -eq $(( len - 10 )) ]] || { err "Connection closed by server"; return 1; }
    read_exact 2 >/dev/null
}

more_waiting() {
    local _
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        read -t 0 -u 3 && return 0
        sleep 0.02
    done
    return 1
}

send_packet 3 "$password"
read_packet || exit 1
(( pkt_id == -1 )) && die "RCON login failed - check rcon.password"

run_command() {
    local cmd=${1#"${1%%[!/]*}"}
    send_packet 2 "$cmd"
    read_packet || return 1
    reply=$pkt_body
    while (( BASH_VERSINFO[0] >= 4 && ${#pkt_body} >= 4096 )); do
        more_waiting || break
        read_packet 2>/dev/null || break
        reply+=$pkt_body
    done
    reply=${reply//§?/}
    [[ -n $reply ]] && printf '%s\n' "$reply"
    return 0
}

if (( $# )); then
    run_command "$*"
    status=$?
    exec 3>&-
    exit "$status"
fi

printf '%s\n' "${green}Connected to server console. Type 'exit' to leave.${reset}"
shopt -s nocasematch
while :; do
    IFS= read -r -e -p '> ' cmd || { echo; break; }
    case $cmd in exit|quit) break ;; esac
    [[ -z ${cmd//[[:space:]]/} ]] && continue
    history -s -- "$cmd"
    run_command "$cmd" || exit 1
    [[ $cmd == stop || $cmd == /stop ]] && break
done
exec 3>&-
