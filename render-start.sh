#!/bin/sh
# Render startup: if ALCHEMY_RPC_URL is set (Render env var, never committed), use it as the primary RPC. Then hand over to PoWFaucet's entrypoint.
CFG=/data/faucet-config.yaml
if [ -n "$ALCHEMY_RPC_URL" ]; then
  TMP=/data/.faucet-config.tmp
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ethRpcHost:*)
        # order measured by latency (eth_blockNumber, median): alchemy 118ms, publicnode 121ms,
        # drpc 139ms, mainnet.base.org 117ms (rate-limited, sometimes stale), meowrpc 318ms, pocket 520ms
        # (thirdweb removed: public endpoint rate-limited)
        printf '%s\n' "ethRpcHost:" \
          "  - url: \"$ALCHEMY_RPC_URL\"" '    name: "alchemy"' '    priority: 10' \
          '  - url: "https://base-rpc.publicnode.com"' '    name: "publicnode"' '    priority: 9' \
          '  - url: "https://base.drpc.org"' '    name: "drpc"' '    priority: 8' '    metered: true' \
          '  - url: "https://mainnet.base.org"' '    name: "base-public"' '    priority: 7' '    metered: true' \
          '  - url: "https://base.meowrpc.com"' '    name: "meowrpc"' '    priority: 6' '    metered: true' \
          '  - url: "https://base.api.pocket.network"' '    name: "pocket"' '    priority: 5' '    metered: true' ;;
      *) printf '%s\n' "$line" ;;
    esac
  done < "$CFG" > "$TMP" && cat "$TMP" > "$CFG" && rm -f "$TMP"
  echo "render-start: RPCs by speed: alchemy, publicnode, drpc, mainnet.base.org, meowrpc, pocket"
else
  echo "render-start: ALCHEMY_RPC_URL not set, using mainnet.base.org only"
fi
exec /entrypoint.sh "$@"
