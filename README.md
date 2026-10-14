# shadowrocket-sync

Merge [Johnshall forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) rules with local permanent overrides, then publish:

- `flyint.conf` — Shadowrocket remote config  
- `flyint.yaml` — Clash / Mihomo profile  

Upstream banlist stays on a schedule; your AI / Apple / Host overrides are never overwritten by upstream.

## Layout

| File | Purpose |
|------|---------|
| `apple.override.conf` | App Store / Apple update → `direct` (highest priority) |
| `ai.override.conf` | Google / OpenAI / Claude / Cursor → `Proxy`; CN AI → `direct` |
| `host.override.conf` | Local `[Host]` (create from `.example`, gitignored) |
| `subscription.url` | Optional Clash node subscription URL (gitignored) |
| `config.env` | `GIST_ID` / raw URLs (gitignored) |
| `sync.sh` | Fetch upstream → merge → write `out/` → patch Gist |

## Quick start

```bash
git clone https://github.com/longyunBegin/shadowrocket-sync.git
cd shadowrocket-sync

cp host.override.conf.example host.override.conf   # edit if needed
cp subscription.url.example subscription.url       # optional
# ai.override.conf / apple.override.conf are ready to edit

# needs: gh (gist scope), jq, curl, python3
gh auth login -h github.com -p https -w -s gist

./setup-gist.sh          # create private gist + config.env
./install-launchd.sh     # macOS: daily 09:10 sync
./sync.sh                # manual run anytime
```

Subscribe phones / Clash Verge to the raw URLs printed by `sync.sh` / `setup-gist.sh`. Enable client auto-update (e.g. every 24h).

## Manual update

```bash
./sync.sh
```

Edit only the `*.override.conf` files (and optional `subscription.url`), never hand-edit `out/flyint.*`.

## Security notes

- This repo is **public**: do **not** commit `config.env`, real subscription URLs, or private Host/DNS if sensitive.
- Publish target is usually a **secret Gist** (URL is the capability). Keep that URL out of issues/PRs if you care.
- Node subscription links belong in local `subscription.url` only.

## Requirements

- macOS recommended for LaunchAgent; `sync.sh` itself is portable zsh + python3
- [GitHub CLI](https://cli.github.com/) with `gist` scope
- `jq`
