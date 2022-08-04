#!/usr/bin/env sh

if [ -z "$KRAKEN_BROKER_password" ] && [ -n "$KRAKEN_BROKER_password_FILE" ]; then
    if ! [ -f "$KRAKEN_BROKER_password_FILE" ]; then
      echo "Unable to locate file $KRAKEN_BROKER_password_FILE" >&2
      exit 2
    fi  
    export KRAKEN_BROKER_password="$(cat "$KRAKEN_BROKER_password_FILE" | tr -d '\n')"
  fi
fi

exec "$@"
