#!/bin/sh
# Render startup: if ALCHEMY_RPC_URL is set (Render env var, never committed), use it as the primary RPC
# and keep the public sepolia.base.org as a lower-priority backup. Then hand over to PoWFaucet's entrypoint.
CFG=/data/faucet-config.yaml
if [ -n "$ALCHEMY_RPC_URL" ]; then
  TMP=/data/.faucet-config.tmp
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ethRpcHost:*)
        printf '%s\n' "ethRpcHost:" \
          "  - url: \"$ALCHEMY_RPC_URL\"" '    name: "alchemy"' '    priority: 10' \
          '  - url: "https://sepolia.base.org"' '    name: "base-public"' '    priority: 5' '    metered: true' ;;
      *) printf '%s\n' "$line" ;;
    esac
  done < "$CFG" > "$TMP" && cat "$TMP" > "$CFG" && rm -f "$TMP"
  echo "render-start: Alchemy RPC enabled as primary, sepolia.base.org as backup"
else
  echo "render-start: ALCHEMY_RPC_URL not set, using sepolia.base.org only"
fi
exec /entrypoint.sh "$@"
