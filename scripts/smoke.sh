#!/bin/sh
# Checks a built tarball the way a user would use it: unpacks it, fills in
# the wrappers' libexec as the formula does, and runs `cargo flux` on a tiny
# crate twice: once correct, which must pass, and once wrong, which Flux
# must refuse.
#   scripts/smoke.sh <tarball> <inputs.json>
set -eu
tarball=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
flux=$(jq -er .flux "$2")
here=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/flux-smoke.XXXXXX")
tar -xzf "$tarball" -C "$work"
root="$work/flux-toolchain"
for b in cargo-flux flux; do
    sed -i '' "s|@@LIBEXEC@@|$root/libexec|" "$root/bin/$b"
done
cp -R "$here/smoke" "$work/crate"
sed -i '' "s|@@FLUX@@|$flux|" "$work/crate/Cargo.toml"
PATH="$root/bin:$PATH"
export PATH
unset FLUX_SYSROOT
cd "$work/crate"
cargo flux --version
cargo flux
sed -i '' 's/^    x$/    x - 1/' src/lib.rs
if cargo flux; then
    echo "smoke: Flux passed a function that breaks its signature" >&2
    exit 1
fi
echo "smoke: Flux passed the correct function and refused the wrong one" >&2
rm -rf "$work"
