#!/bin/sh
# Render startup: if ALCHEMY_RPC_URL is set (Render env var, never committed), use it as the primary RPC. Then hand over to PoWFaucet's entrypoint.
CFG=/data/faucet-config.yaml
if [ -n "$ALCHEMY_RPC_URL" ]; then
  TMP=/data/.faucet-config.tmp
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ethRpcHost:*)
        # order measured by latency (eth_blockNumber, median): alchemy 118ms, publicnode 121ms,
        # mainnet.base.org 120ms (rate-limited, metered), pocket 509ms (thirdweb removed: public endpoint rate-limited)
        printf '%s\n' "ethRpcHost:" \
          "  - url: \"$ALCHEMY_RPC_URL\"" '    name: "alchemy"' '    priority: 10' \
          '  - url: "https://base-rpc.publicnode.com"' '    name: "publicnode"' '    priority: 9' \
          '  - url: "https://mainnet.base.org"' '    name: "base-public"' '    priority: 7' '    metered: true' \
          '  - url: "https://base.api.pocket.network"' '    name: "pocket"' '    priority: 5' '    metered: true' ;;
      *) printf '%s\n' "$line" ;;
    esac
  done < "$CFG" > "$TMP" && cat "$TMP" > "$CFG" && rm -f "$TMP"
  echo "render-start: RPCs by speed: alchemy, publicnode, mainnet.base.org, pocket"
else
  echo "render-start: ALCHEMY_RPC_URL not set, using mainnet.base.org only"
fi
exec /entrypoint.sh "$@"
