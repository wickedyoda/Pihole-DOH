#!/bin/sh
set -eu

: "${DOH_SERVER_STAMP:?DOH_SERVER_STAMP must be set}"

DOH_SERVER_NAME="${DOH_SERVER_NAME:-custom-doh}"
DNSCRYPT_LISTEN_ADDRESS="${DNSCRYPT_LISTEN_ADDRESS:-0.0.0.0:5053}"
DNSCRYPT_BOOTSTRAP_RESOLVERS="${DNSCRYPT_BOOTSTRAP_RESOLVERS:-9.9.9.9:53,1.1.1.1:53}"

BOOTSTRAP_TOML=""
OLD_IFS="$IFS"
IFS=","
for resolver in $DNSCRYPT_BOOTSTRAP_RESOLVERS; do
  trimmed="$(printf '%s' "$resolver" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -n "$trimmed" ] || continue
  if [ -n "$BOOTSTRAP_TOML" ]; then
    BOOTSTRAP_TOML="$BOOTSTRAP_TOML, "
  fi
  BOOTSTRAP_TOML="$BOOTSTRAP_TOML'$trimmed'"
done
IFS="$OLD_IFS"

if [ -z "$BOOTSTRAP_TOML" ]; then
  BOOTSTRAP_TOML="'9.9.9.9:53'"
fi

export DOH_SERVER_NAME
export DOH_SERVER_STAMP
export DNSCRYPT_LISTEN_ADDRESS
export BOOTSTRAP_TOML

envsubst '${DOH_SERVER_NAME} ${DOH_SERVER_STAMP} ${DNSCRYPT_LISTEN_ADDRESS} ${BOOTSTRAP_TOML}' \
  < /templates/dnscrypt-proxy.toml.tpl \
  > /config/dnscrypt-proxy.toml

exec dnscrypt-proxy -config /config/dnscrypt-proxy.toml
