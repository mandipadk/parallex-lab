#!/bin/zsh
# Download the latest released Parallex from parallex.mandip.dev, check it
# against the checksum published with the release, and unpack it.
#
#   ./fetch-parallex.sh [DIR]
#
# Leaves DIR/Parallex.app (default: next to this script) and writes the
# version to DIR/parallex-version.txt. The lab uses the parallex command
# inside it: Parallex.app/Contents/Resources/parallex.
set -euo pipefail

here=${0:A:h}
dest=${1:-$here}
site=https://parallex.mandip.dev
mkdir -p "$dest"
dest=${dest:A}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# /download/latest/Parallex.zip redirects to the newest release's zip,
# /download/<version>/Parallex-<version>.zip; that names the version.
effective=$(curl -fsSL --retry 3 -o "$work/Parallex.zip" -w '%{url_effective}' "$site/download/latest/Parallex.zip")
version=${${effective:t}#Parallex-}
version=${version%.zip}
if [[ ! $version =~ '^[0-9]+(\.[0-9]+)+$' ]]; then
  # Otherwise ask the update feed which release is the latest.
  version=$(curl -fsS --retry 3 -H 'X-Parallex-Version: 0.0.0' "$site/api/v1/releases/latest" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))')
fi
[[ $version =~ '^[0-9]+(\.[0-9]+)+$' ]] || { echo "can't tell which version was downloaded" >&2; exit 1 }

zip=Parallex-$version.zip
mv "$work/Parallex.zip" "$work/$zip"
curl -fsSL --retry 3 -o "$work/$zip.sha256" "$site/download/$version/$zip.sha256"
(cd "$work" && shasum -a 256 -c "$zip.sha256") || { echo "$zip doesn't match its published checksum" >&2; exit 1 }

rm -rf "$dest/Parallex.app"
ditto -x -k "$work/$zip" "$dest"
codesign --verify --strict "$dest/Parallex.app" || { echo "Parallex.app's signature doesn't check out" >&2; exit 1 }
cli=$dest/Parallex.app/Contents/Resources/parallex
[[ -x $cli ]] || { echo "Parallex $version has no parallex command at $cli" >&2; exit 1 }
print -r -- "$version" > "$dest/parallex-version.txt"
echo "Parallex $version, checked, at $dest/Parallex.app"
