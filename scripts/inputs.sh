#!/bin/sh
# Prints, as JSON, the inputs a build would take today: the newest of each.
#   flux      Flux's main commit
#   rust      the Rust nightly Flux's rust-toolchain.toml names at that commit
#   fixpoint  the commit of liquid-fixpoint's nightly release
#   z3        z3's latest release tag
# Needs gh, logged in or given GH_TOKEN, and jq.
set -eu
flux=$(gh api repos/flux-rs/flux/commits/main --jq .sha)
rust=$(gh api "repos/flux-rs/flux/contents/rust-toolchain.toml?ref=$flux" --jq .content |
    base64 --decode | sed -n 's/^channel *= *"\(.*\)"$/\1/p')
fixpoint=$(gh api repos/ucsd-progsys/liquid-fixpoint/commits/nightly --jq .sha)
z3=$(gh api repos/Z3Prover/z3/releases/latest --jq .tag_name)
for v in "$flux" "$rust" "$fixpoint" "$z3"; do
    [ -n "$v" ] || {
        echo "inputs: one of the inputs read empty: flux=$flux rust=$rust fixpoint=$fixpoint z3=$z3" >&2
        exit 1
    }
done
jq -n --arg flux "$flux" --arg rust "$rust" --arg fixpoint "$fixpoint" --arg z3 "$z3" \
    '{flux: $flux, rust: $rust, fixpoint: $fixpoint, z3: $z3}'
