#!/usr/bin/env bash
# Points sources.json at the newest release of Retomodo/sandhouse-releases:
# its version and the .deb's hash. Prints the new version, or nothing when
# sources.json was already current. CI runs it daily (.github/workflows/update.yml);
# run it by hand with `nix develop -c ./update.sh`.
set -euo pipefail
cd "$(dirname "$0")"

repo=Retomodo/sandhouse-releases
file=sandhouse-linux-amd64.deb

tag=$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)
version=${tag#v}

if [ "$(jq -r .version sources.json)" = "$version" ]; then
  exit 0
fi

url="https://github.com/$repo/releases/download/$tag/$file"
hash=$(nix store prefetch-file --json "$url" | jq -r .hash)

jq -n --arg version "$version" --arg url "$url" --arg hash "$hash" \
  '{version: $version, url: $url, hash: $hash}' > sources.json
echo "$version"
