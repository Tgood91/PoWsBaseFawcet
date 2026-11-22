# PoWsBaseFawcet

Two proof-of-work faucets on Base, both running [PoWFaucet](https://github.com/pk910/PoWFaucet) by pk910
unchanged (official image, pinned to `v2.6.0`). This repo only holds their configuration, a `Dockerfile`
and a small startup script.

| Faucet | Gives out | Chain | Branch | Live at |
|---|---|---|---|---|
| Base Sepolia faucet | testnet ETH (no value) | Base Sepolia, 84532 | `main` | https://base-sepolia-pow-faucet.onrender.com |
| Runes faucet | **Runes**, an ERC-20 token | Base mainnet, 8453 | `runes` | https://runes-pow-faucet.onrender.com |

Visitors enter an address, solve a captcha, and mine in their browser for a while, then claim. The mining
does not create anything: it only makes mass requests slow and costly. The faucet wallet is funded by hand.

## What Runes is

Runes is a **Zora content coin** on Base mainnet: an ERC-20 created through Zora's coin factory, which
launches each coin together with its own trading pool.

| | |
|---|---|
| Token | `Runes` (symbol `Runes`), 18 decimals |
| Contract | [`0x68E63f682AB383A9132317349125fF7618C96e01`](https://basescan.org/token/0x68E63f682AB383A9132317349125fF7618C96e01) |
| Created | 9 Nov 2025, by Zora's coin factory [`0x7777…baf3`](https://basescan.org/address/0x777777751622c0d3258f214f9df38e35bf45baf3) |
| Contract type | Zora `ContentCoin`, version 2.3.0 (a minimal proxy of [`0x7cad…861c`](https://basescan.org/address/0x7cad62748ddf516cf85bc2c05c14786d84cf861c)) |
| Total supply | 1,000,000,000 Runes, fixed |
| Owner / payout recipient | [`0xf379…c57E`](https://basescan.org/address/0xf379Bd56F226B26163f5d459018adBcDE400c57E) |
| Metadata | name "Runes", description "Just testing something", category "social" (hosted on the Base app's IPFS gateway) |

### What it's tied to: the pool

Runes isn't priced against ETH or USDC directly. Its pool pairs it with another coin, **TABOSHI**:

| Pool setting | Value |
|---|---|
| Venue | Uniswap v4, through Base's v4 PoolManager [`0x4985…2b2b`](https://basescan.org/address/0x498581fF718922c3f8e6A244956aF099B2652b2b) |
| Pair | **TABOSHI** [`0x3A1a…789f`](https://basescan.org/token/0x3A1a33cf4553Db61F0db2c1e1721CD480b02789f) / **Runes** |
| Fee tier | 1% (`10000`) on every swap |
| Tick spacing | 200 |
| Hook | Zora's v4 coin hook [`0xC8d0…9040`](https://basescan.org/address/0xC8d077444625eB300A427a6dfB2b1DBf9b159040) |
| Supply placed in the pool | 990,000,000 Runes (99%) as liquidity positions at launch |

In practice:

- **Runes is priced in TABOSHI.** Buying Runes means paying TABOSHI into the pool, and selling Runes returns
  TABOSHI. Any ETH or USD price you see is routed through TABOSHI's own markets, so Runes' value moves with TABOSHI's.
- **TABOSHI** is an older Zora-created ERC-20 (created 10 Nov 2024 through Zora's contract `0x7777…56ae`)
  with a supply of about 185,964. It isn't part of this repo, and this repo makes no claim about its value.
- **The hook** is the contract Uniswap v4 calls on every swap. For Zora coins it collects the 1% fee and splits
  it between the coin's payout recipient, the platform referrer
  ([`0x55C8…2453`](https://basescan.org/address/0x55C88bB05602Da94fCe8FEadc1cbebF5B72c2453)) and Zora's protocol.
  The exact split is set by Zora's contracts, not by this repo.
- **Liquidity is thin.** Nearly all supply sits in that one pool, so large trades move the price a lot.
  Treat Runes as an experimental token.

The faucet only **transfers Runes the faucet wallet already holds**. It doesn't mint, trade or touch the pool.

## The faucet wallet

Both faucets use the same burner wallet,
[`0x4342bBb4FA142f2D5E7Fd02e7cFAc9FaF19B9BdE`](https://basescan.org/address/0x4342bBb4FA142f2D5E7Fd02e7cFAc9FaF19B9BdE).
That's safe because each chain keeps its own transaction count. When set up, it held:

- 1 ETH on Base Sepolia, which the Sepolia faucet gives out
- 4,444,444 Runes on Base mainnet, which the Runes faucet gives out
- about 0.0001 ETH on Base mainnet, which pays the Runes faucet's gas. At about 0.006 gwei that covers
  many transfers, but **top it up** if the Runes faucet reports it is out of funds while it still holds Runes.

> **Security:** the wallet's private key has been shared outside the server. Anyone holding it can move the
> Runes and ETH in it. Use it only as a faucet burner, and move to a fresh wallet if that matters.

## Settings

### Runes faucet (`runes` branch)

| Setting | Value |
|---|---|
| Claim size | 100,000 Runes minimum, 250,000 maximum |
| Mining reward | 1,000 Runes per share. At about 200 H/s the minimum takes about 17 min and the maximum about 43 min; at the 500 H/s cap, about 7 and 17 min |
| Per person | 1 claim (250,000) a day per IP/address, 500,000 a week per address |
| Daily budget | about 500,000 Runes a day in total |
| Low balance | rewards halved below 1,000,000 Runes; stops below 250,000 |
| Hoarders | addresses already holding 1,000,000+ Runes are refused |
| Gas | max fee 0.05 gwei, at most 0.001 ETH in fees per claim |

At these settings the 4.44M Runes last for roughly 18–44 claims, or about 9 days at the daily budget.

### Base Sepolia faucet (`main` branch)

| Setting | Value |
|---|---|
| Claim size | 0.025 ETH minimum, 0.25 ETH maximum |
| Mining reward | 0.0004 ETH per share |
| Per person | 0.25 ETH (2 claims) a day per IP/address, 0.5 ETH a week per address |
| Daily budget | about 1 ETH a day |
| Hoarders | addresses already holding 1+ ETH are refused |

### Both faucets

| Setting | Value | Why |
|---|---|---|
| Captcha | hCaptcha when a session starts | stops scripted sessions |
| Hashrate | **500 H/s max**, enforced on the server | a fast machine can't out-mine everyone else |
| Mining | argon2, difficulty 11 | memory-hard, so GPUs don't gain much |
| Bot checks | rewards cut 90% for hosting and proxy IPs | bot farms usually run from data centres |
| `httpProxyCount` | 3 | Render puts Cloudflare plus two internal hops in front. With 3 the faucet sees each visitor's real IP, so per-IP limits work |
| RPC | Alchemy (primary), then PublicNode, mainnet.base.org and Pocket Network as backups, ordered by measured latency | the public RPCs are rate-limited or sometimes serve stale blocks |

## Deploying (Render)

Each faucet is a Render web service (Docker runtime) built from its branch. A push to the branch redeploys it.

- `Dockerfile` starts from `pk910/powfaucet:v2.6.0` and copies `data/faucet-config.yaml` into the image.
- `render-start.sh` runs first. If `ALCHEMY_RPC_URL` is set, it makes Alchemy the primary RPC and keeps the
  public Base RPC as backup. Then it starts PoWFaucet.

Environment variables, set on Render and **never committed**:

| Variable | What it is |
|---|---|
| `FAUCET_ETH_WALLET_KEY` | faucet wallet private key (64 hex, no `0x`) |
| `FAUCET_SECRET` | long random string that signs sessions (`openssl rand -hex 40`) |
| `FAUCET_CAPTCHA_SECRET` | hCaptcha **secret** key (`ES_…`). The public site key is in the config |
| `ALCHEMY_RPC_URL` | `https://base-mainnet.g.alchemy.com/v2/<key>` for Runes, `https://base-sepolia.g.alchemy.com/v2/<key>` for Sepolia |

On Render's **free plan** a service sleeps after 15 minutes without visitors (about a minute to wake), and its
database resets on every restart or redeploy. That clears per-person limits and unfinished sessions. A paid
instance with a persistent disk mounted at `/data` keeps them.

To use the captcha on a new hostname, add it to the site's allowed hostnames in the hCaptcha dashboard.

## Running locally

With Docker:

```sh
cp .env.example .env          # fill in the variables above
chown -R 101:101 data         # the container runs as uid 101
docker compose up -d
docker compose logs -f        # should show the config loading and the faucet wallet's address and balance
```

On Windows without Docker (PoWFaucet built in `%USERPROFILE%\powfaucet-src`): double-click
`Set faucet key.cmd`, then `Start faucet.cmd`, and open http://localhost:8080. To publish it from your own
machine, `cloudflared tunnel --url http://localhost:8080` gives a temporary public link. Use
`httpProxyCount: 1` in that case.

**Run only one faucet per chain with the same wallet.** Two faucets sending from one wallet on the same chain
compete for transaction numbers.

## Upgrading PoWFaucet

Change the image tag in `Dockerfile` and `docker-compose.yml` to a newer
[release](https://github.com/pk910/PoWFaucet/releases), compare `data/faucet-config.yaml` with that release's
`faucet-config.example.yaml`, then push.

## License

This repo is GPL-3.0 (see LICENSE). `data/faucet-config.yaml` is derived from PoWFaucet's example config, which
is AGPL-3.0, so that file is also covered by AGPL-3.0 (see LICENSE-AGPL-3.0); GPL-3.0 and AGPL-3.0 are
compatible (section 13 of each). PoWFaucet itself runs from its own image and stays AGPL-3.0: if you change its
code and run it publicly, the AGPL requires you to publish those changes.
