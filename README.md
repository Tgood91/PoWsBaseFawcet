# PoWsBaseFawcet
"PoW" base sepolia etherem or "gas"

A proof-of-work faucet for **Base Sepolia** testnet ETH (chain 84532), running
[PoWFaucet](https://github.com/pk910/PoWFaucet) by pk910 unchanged. This repo only holds the Base Sepolia
configuration and a Docker Compose file; the faucet itself is PoWFaucet's official image, pinned to `v2.6.0`.

Visitors enter a Base Sepolia address and mine in their browser for a while, then claim. The mining does not
create ETH: it only makes mass requests slow and costly. You fund the faucet wallet yourself.

## What you need

- A server that stays on (any small VPS), with Docker and Docker Compose.
- A **new wallet used only for this faucet**. Never reuse a wallet that holds real funds: its private key sits on
  the server.
- Base Sepolia ETH to hand out, sent to that wallet.
- Optional but recommended: a domain with HTTPS in front (Caddy, nginx or Cloudflare), and an
  [hCaptcha](https://hcaptcha.com) account.

## Run it

```sh
git clone <this repo> && cd <this repo>
cp .env.example .env          # then edit .env: wallet key and a random FAUCET_SECRET
chown -R 101:101 data         # the container runs as uid 101 and writes its database and logs here
docker compose up -d
docker compose logs -f        # should show the config loading and the faucet wallet address and balance:
                              # check the address is 0x4342bBb4FA142f2D5E7Fd02e7cFAc9FaF19B9BdE
```

The faucet is then on port 8080. Put your HTTPS proxy in front of it, and set `httpProxyCount: 1` in
`data/faucet-config.yaml` when you do. Otherwise every visitor appears to come from the proxy's IP and the
per-IP limits stop working.

## The settings (data/faucet-config.yaml)

| Setting | Value | Why |
|---|---|---|
| Chain | Base Sepolia, 84532, `https://sepolia.base.org` | The public RPC is rate-limited; use your own RPC URL for real traffic |
| Faucet wallet | burner `0x4342bBb4FA142f2D5E7Fd02e7cFAc9FaF19B9BdE` | Its key goes in `.env` on the server only |
| Claim size | 0.025 ETH minimum, 0.25 ETH maximum | |
| Per person | 0.25 ETH (2 claims) a day per IP/address, 0.5 ETH a week per address | |
| Daily budget | about 1 ETH a day in total, however many people mine | Bounds how fast the wallet can drain |
| Low balance | rewards halved below 0.5 ETH; stops below 0.27 ETH so a full claim can always be paid | |
| Bot checks | rewards cut 90% for hosting and proxy IPs; addresses already holding 1 ETH refused | |
| Smart wallets | allowed (100k gas limit) | Smart-contract wallets are common on Base |
| Captcha | **off** until you add keys | Turn on: set the site key, put `FAUCET_CAPTCHA_SECRET` in `.env`, set `enabled: true` |

`powShareReward` (0.001 ETH per share: 25 shares for the minimum claim, 250 for the cap) decides how long people mine for a claim. It's a starting guess:
watch the first sessions and tune it. After changing the config, run `docker compose restart`.

## Secrets

The wallet key, faucet secret and captcha secret are read from environment variables (`.env`), never from the
config file, so the config is safe to commit. `.env` is git-ignored. Keep it that way.

## Upgrading PoWFaucet

Change the image tag in `docker-compose.yml` to a newer [release](https://github.com/pk910/PoWFaucet/releases),
compare our config against that release's `faucet-config.example.yaml`, then `docker compose pull && docker compose up -d`.

## License

This repo is GPL-3.0 (see LICENSE). `data/faucet-config.yaml` is derived from PoWFaucet's example config, which
is AGPL-3.0, so that file is also covered by AGPL-3.0 (see LICENSE-AGPL-3.0); GPL-3.0 and AGPL-3.0 are
compatible (section 13 of each). PoWFaucet itself runs from its own image and stays AGPL-3.0: if you change its
code and run it publicly, the AGPL requires you to publish those changes.
