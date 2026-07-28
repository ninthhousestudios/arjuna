#!/usr/bin/env bash
# Guard for quiver/Dockerfile's `COPY arrow/swe/.dart_tool/lib/libswisseph_rs_dart.so`.
#
# `dart compile exe` does not invoke native asset build hooks, so the image ships a
# host-built .so from the build context. Nothing links that file to the resolved
# swisseph_rs version: `dart pub get` updates pubspec.lock and package_config.json and
# leaves .dart_tool/lib/ untouched, so a version bump silently keeps shipping the .so
# from whenever hooks last ran. See docs/swisseph-rs-native-lib.md.
#
# Exits non-zero if the staged .so is not byte-identical to the resolved package's
# release build.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
staged="$repo_root/arrow/swe/.dart_tool/lib/libswisseph_rs_dart.so"
package_config="$repo_root/.dart_tool/package_config.json"

if [[ ! -f "$package_config" ]]; then
  echo "error: $package_config missing — run 'dart pub get' first" >&2
  exit 1
fi

# Resolve swisseph_rs's package root from package_config.json rather than parsing a
# version out of pubspec.lock: this works unchanged for hosted, git, and path
# resolutions, and it is the same root the build hook compiles.
package_root="$(
  python3 - "$package_config" <<'PY'
import json, sys
from urllib.parse import urlparse
from urllib.request import url2pathname

with open(sys.argv[1]) as f:
    config = json.load(f)

for package in config["packages"]:
    if package["name"] == "swisseph_rs":
        print(url2pathname(urlparse(package["rootUri"]).path).rstrip("/"))
        break
else:
    sys.exit("error: swisseph_rs not found in package_config.json")
PY
)"

expected="$package_root/rust/target/release/libswisseph_rs_dart.so"

hint() {
  cat >&2 <<EOF

Rebuild it by running the native asset hooks, then re-run this check:

    cd $repo_root/arrow/swe && dart test test/julian_day_test.dart

Resolved swisseph_rs: $package_root
EOF
}

if [[ ! -f "$staged" ]]; then
  echo "error: staged native lib missing: $staged" >&2
  hint
  exit 1
fi

if [[ ! -f "$expected" ]]; then
  echo "error: resolved swisseph_rs has no release build: $expected" >&2
  echo "       the staged .so therefore cannot be from the resolved version." >&2
  hint
  exit 1
fi

if ! cmp -s "$staged" "$expected"; then
  echo "error: staged native lib is stale — it is not the resolved swisseph_rs build." >&2
  echo "       staged:   $staged ($(stat -c %y "$staged"))" >&2
  echo "       resolved: $expected ($(stat -c %y "$expected"))" >&2
  hint
  exit 1
fi

echo "ok: libswisseph_rs_dart.so matches resolved swisseph_rs at $package_root"
