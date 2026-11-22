# Render build: PoWFaucet's official image (pinned) with this repo's Base Sepolia config baked in.
# Secrets (FAUCET_ETH_WALLET_KEY, FAUCET_SECRET) come from Render environment variables, never from this repo.
FROM pk910/powfaucet:v2.6.0
COPY --chown=nginx:nginx data/faucet-config.yaml /data/faucet-config.yaml
