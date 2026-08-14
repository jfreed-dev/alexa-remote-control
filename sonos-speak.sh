#!/usr/bin/env bash
# sonos-speak.sh — Send TTS to Sonos speakers via node-sonos-http-api on Spark
#
# Usage:
#   sonos-speak.sh "Kitchen" "Dinner is ready"
#   sonos-speak.sh --all "Hello everyone"
#   sonos-speak.sh -v 40 "Living Room" "Turn it up"
#   sonos-speak.sh --list

set -euo pipefail

SONOS_API="http://10.10.88.120:5005"
VOLUME=25
LANG="en-us"
ALL_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all|-a)
            ALL_MODE=true
            shift
            ;;
        --volume|-v)
            VOLUME="$2"
            shift 2
            ;;
        --list|-l)
            curl -s "${SONOS_API}/zones" | jq -r '.[].members[].roomName'
            exit 0
            ;;
        --help|-h)
            echo "Usage: sonos-speak.sh [options] <room> <message>"
            echo "       sonos-speak.sh --all <message>"
            echo "       sonos-speak.sh --list"
            echo ""
            echo "Options:"
            echo "  --all, -a          Speak on all Sonos speakers"
            echo "  --volume, -v NUM   Set volume (0-100, default 25)"
            echo "  --list, -l         List available rooms"
            echo "  --help, -h         Show this help"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if $ALL_MODE; then
    if [ $# -lt 1 ]; then
        echo "Usage: sonos-speak.sh --all <message>" >&2
        exit 1
    fi
    MESSAGE="$*"
    ENCODED=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$MESSAGE")
    curl -s "${SONOS_API}/sayall/${ENCODED}/${LANG}/${VOLUME}"
else
    if [ $# -lt 2 ]; then
        echo "Usage: sonos-speak.sh <room> <message>" >&2
        exit 1
    fi
    ROOM="$1"
    shift
    MESSAGE="$*"
    ENCODED_ROOM=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$ROOM")
    ENCODED_MSG=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$MESSAGE")
    curl -s "${SONOS_API}/${ENCODED_ROOM}/say/${ENCODED_MSG}/${LANG}/${VOLUME}"
fi
echo ""
