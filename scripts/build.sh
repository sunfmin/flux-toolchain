#!/bin/sh
# Builds one version of the toolchain on Apple silicon macOS.
#   scripts/build.sh <inputs.json> <version> <out dir>
# Writes <out dir>/flux-toolchain-<version>-macos-arm64.tar.gz, which holds
#   bin/cargo-flux, bin/flux        the wrappers (scripts/wrapper.sh)
#   libexec/bin/cargo-flux, flux    Flux's own binaries, built from source
#   libexec/bin/fixpoint            liquid-fixpoint's nightly binary
#   libexec/bin/z3                  z3's release binary
#   libexec/sysroot/                flux-driver and Flux's precompiled libraries
#   inputs.json                     what it was built from
# Flux publishes no binaries, so it is the one part built here; the other two
# are upstream's own builds, repackaged.
set -eu
inputs=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
version=$2
mkdir -p "$3"
out=$(cd "$3" && pwd)
here=$(cd "$(dirname "$0")" && pwd)
[ "$(uname -s)-$(uname -m)" = Darwin-arm64 ] || {
    echo "build: builds only on Apple silicon macOS, not $(uname -s) $(uname -m)" >&2
    exit 1
}
read_input() { jq -er ".$1" "$inputs"; }
flux=$(read_input flux)
rust=$(read_input rust)
fixpoint=$(read_input fixpoint)
z3=$(read_input z3)
work=$(mktemp -d "${TMPDIR:-/tmp}/flux-toolchain.XXXXXX")
stage="$work/flux-toolchain"
mkdir -p "$stage/bin" "$stage/libexec/bin"

echo "build: Flux $flux on Rust $rust" >&2
git init --quiet "$work/flux"
git -C "$work/flux" fetch --quiet --depth 1 https://github.com/flux-rs/flux.git "$flux"
git -C "$work/flux" checkout --quiet FETCH_HEAD
rustup toolchain install "$rust" --profile minimal \
    --component rust-src,rustc-dev,llvm-tools,rustfmt,clippy
cargo_bin="${CARGO_HOME:-$HOME/.cargo}/bin"
(cd "$work/flux" && env -u RUSTUP_TOOLCHAIN FLUX_HOME="$work/flux-home" cargo xtask install)
cp "$cargo_bin/cargo-flux" "$cargo_bin/flux" "$stage/libexec/bin/"
cp -R "$work/flux-home/sysroot" "$stage/libexec/sysroot"

echo "build: liquid-fixpoint nightly $fixpoint" >&2
curl -fsSL "https://github.com/ucsd-progsys/liquid-fixpoint/releases/download/nightly/fixpoint-aarch64-apple-darwin.tar.gz" |
    tar -xz -C "$stage/libexec/bin" fixpoint
chmod +x "$stage/libexec/bin/fixpoint"
# The nightly tag moves: what was downloaded must be the commit read.
"$stage/libexec/bin/fixpoint" --version | grep -q "($fixpoint)" || {
    echo "build: the fixpoint nightly moved since the inputs were read: it reports $("$stage/libexec/bin/fixpoint" --version | tail -1), not $fixpoint" >&2
    exit 1
}

echo "build: $z3" >&2
z3_zip=$(gh api "repos/Z3Prover/z3/releases/tags/$z3" \
    --jq '.assets[].browser_download_url | select(test("-arm64-osx-[^/]*\\.zip$"))' | head -1)
[ -n "$z3_zip" ] || {
    echo "build: the z3 release $z3 has no arm64-osx zip" >&2
    exit 1
}
curl -fsSL -o "$work/z3.zip" "$z3_zip"
unzip -q "$work/z3.zip" -d "$work/z3"
cp "$work"/z3/*/bin/z3 "$stage/libexec/bin/z3"

for b in cargo-flux flux; do
    sed "s|@@TOOLCHAIN@@|$rust|" "$here/wrapper.sh" >"$stage/bin/$b"
    chmod +x "$stage/bin/$b"
done
cp "$inputs" "$stage/inputs.json"
tarball="$out/flux-toolchain-$version-macos-arm64.tar.gz"
tar -czf "$tarball" -C "$work" flux-toolchain
echo "build: wrote $tarball" >&2
rm -rf "$work"
