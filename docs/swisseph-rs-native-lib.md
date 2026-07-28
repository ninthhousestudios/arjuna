# Updating swisseph_rs

Bumping `swisseph_rs` in `pubspec.yaml` is only half the update. The Dart side comes
from `pub get`; the native library does not, and quiver's Docker image ships the native
library from this working tree. **Run the build hooks deliberately after every bump.**

## Why

`quiver/Dockerfile` copies a host-built artifact into the image:

```dockerfile
COPY arrow/swe/.dart_tool/lib/libswisseph_rs_dart.so /app/lib/
```

It does this because `dart compile exe` (3.12) does not invoke native asset build
hooks, so the AOT binary has no way to produce the `.so` itself. At runtime the
Dockerfile `LD_PRELOAD`s that file.

`dart pub get` writes `pubspec.lock` and `.dart_tool/package_config.json` and touches
nothing native. `.dart_tool/lib/` is written only when the native asset build hook
actually runs, which happens under `dart run` / `dart test` / `flutter build` — not
under `pub get` and not under `dart compile exe`. So after a bump the lockfile says the
new version while `.dart_tool/lib/` still holds the `.so` from whenever hooks last ran,
and `docker build` copies the stale one without complaint.

This has already happened once: quiver shipped the `swisseph_rs` **0.2.5** native
library under 0.3.1 Dart bindings. The ABI is identical (same 91 exported symbols), so
nothing failed to link — but the 0.2.5 native code predates the 0.2.9 `swisseph-ffi`
bump that fixed an infinite Newton loop in crossing refinement against DE441. A
crossing-refinement call could hang the worker rather than return an error, and the
Dart `NoConvergenceException` arm was dead code because the old `.so` never emits the
`-17` code that raises it. Version skew here is silent by default and behavioural, not
a startup failure.

## How to update

```bash
cd /home/josh/nhs/soft/astrology/arjuna

# 1. Bump the constraint in the relevant pubspec.yaml, then resolve.
dart pub get

# 2. Run the build hooks. Any dart run/dart test in a package that depends on
#    arrow_swe works; this test is fast and pulls the whole native chain.
cd arrow/swe && dart test test/julian_day_test.dart && cd ../..

# 3. Verify the staged .so is the resolved version's build.
./scripts/check-quiver-native-lib.sh
```

Step 2 compiles the Rust shim from the resolved package's `rust/` directory, so the
first run after a bump takes a cargo release build (a minute or two), not seconds.
`Running build hooks...File modified during build. Build must be rerun.` on that first
run is expected — the hook writes into the `rust/target/` tree it is watching, and it
reruns and succeeds.

Step 3 is the guard. It resolves `swisseph_rs`'s package root from
`package_config.json` (so it works for hosted, git, and path resolutions alike) and
byte-compares `arrow/swe/.dart_tool/lib/libswisseph_rs_dart.so` against that package's
`rust/target/release/` build. It is wired into `docs/quiver-build-push.md` ahead of
`docker build`; run it there or as its own step, but do not push an image without it.

## Checking what's in a built image

```bash
docker run --rm --entrypoint md5sum <image> /app/lib/libswisseph_rs_dart.so
md5sum ~/.pub-cache/hosted/pub.dev/swisseph_rs-<version>/rust/target/release/libswisseph_rs_dart.so
```

If those differ, the image is not running the `swisseph_rs` version its Dart code was
compiled against.
