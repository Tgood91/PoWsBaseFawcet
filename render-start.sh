#!/bin/sh
# Render startup: if ALCHEMY_RPC_URL is set (Render env var, never committed), use it as the primary RPC
# and keep the public sepolia.base.org as a lower-priority backup. Then hand over to PoWFaucet's entrypoint.
CFG=/data/faucet-config.yaml
if [ -n "$ALCHEMY_RPC_URL" ]; then
  TMP=/data/.faucet-config.tmp
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ethRpcHost:*)
        # Base Sepolia, order measured by latency (eth_blockNumber, median): alchemy 167ms, publicnode 144ms,
        # drpc 167ms, sepolia.base.org 137ms (rate-limited, sometimes stale), pocket 523ms. MeowRPC has no Sepolia endpoint.
        printf '%s\n' "ethRpcHost:" \
          "  - url: \"$ALCHEMY_RPC_URL\"" '    name: "alchemy"' '    priority: 10' \
          '  - url: "https://base-sepolia-rpc.publicnode.com"' '    name: "publicnode"' '    priority: 9' \
          '  - url: "https://base-sepolia.drpc.org"' '    name: "drpc"' '    priority: 8' '    metered: true' \
          '  - url: "https://sepolia.base.org"' '    name: "base-public"' '    priority: 7' '    metered: true' \
          '  - url: "https://base-testnet.api.pocket.network"' '    name: "pocket"' '    priority: 5' '    metered: true' ;;
      *) printf '%s\n' "$line" ;;
    esac
  done < "$CFG" > "$TMP" && cat "$TMP" > "$CFG" && rm -f "$TMP"
  echo "render-start: RPCs by speed: alchemy, publicnode, drpc, sepolia.base.org, pocket"
else
  echo "render-start: ALCHEMY_RPC_URL not set, using sepolia.base.org only"
fi
exec /entrypoint.sh "$@"
