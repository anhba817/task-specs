#!/usr/bin/env sh
# Copy shared/references/ into every skill. Each skill must be self-contained
# because `npx skills add --skill <name>` installs one directory.
set -eu
cd "$(dirname "$0")/.."

for skill in skills/*/; do
  [ -f "${skill}SKILL.md" ] || continue
  rm -rf "${skill}references"
  mkdir -p "${skill}references"
  cp -R shared/references/. "${skill}references/"
  echo "synced -> ${skill}references"
done
