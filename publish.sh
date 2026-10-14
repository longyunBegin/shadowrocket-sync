#!/bin/zsh
set -euo pipefail
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/config.env"
OUT_CONF="${OUT_FILE:-$SCRIPT_DIR/out/flyint.conf}"
OUT_YAML="${OUT_YAML:-$SCRIPT_DIR/out/flyint.yaml}"
RAW_URL_YAML="${RAW_URL_YAML:-${RAW_URL/flyint.conf/flyint.yaml}}"

if ! gh auth status >/dev/null 2>&1; then
  print -r -- "gh 未登录或 token 失效。请先执行："
  print -r -- "  gh auth login -h github.com -p https -w -s gist"
  exit 1
fi
[[ -n "${GIST_ID:-}" ]] || { print -r -- "config.env 缺少 GIST_ID"; exit 1; }
[[ -f "$OUT_CONF" && -f "$OUT_YAML" ]] || { print -r -- "缺少 conf/yaml，先跑 sync.sh"; exit 1; }
command -v jq >/dev/null || { print -r -- "需要 jq"; exit 1; }

print -r -- "publishing conf+yaml -> gist $GIST_ID ..."
jq -n --rawfile conf "$OUT_CONF" --rawfile yaml "$OUT_YAML" \
  '{files:{"flyint.conf":{content:$conf},"flyint.yaml":{content:$yaml}}}' \
  | gh api -X PATCH "gists/$GIST_ID" --input - >/dev/null
print -r -- "OK"
print -r -- "Shadowrocket: $RAW_URL"
print -r -- "Clash YAML:   $RAW_URL_YAML"
