#!/bin/sh
# Installed as bin/cargo-flux and bin/flux. It runs the real binary of the
# same name in libexec, with fixpoint, z3 and huacnlee/cargo (as `cargo`) on
# the PATH and the sysroot shipped beside them, and first adds the Rust
# nightly Flux was built with when rustup lacks it. The build fills in the
# toolchain; the formula fills in libexec, where Homebrew put it.
libexec="@@LIBEXEC@@"
toolchain="@@TOOLCHAIN@@"
PATH="$libexec/bin:$HOME/.cargo/bin:$PATH"
: "${FLUX_SYSROOT:=$libexec/sysroot}"
export PATH FLUX_SYSROOT
# The formula decides which huacnlee/cargo runs; it does not update itself.
CARGO_FORK_AUTO_UPDATE=0
export CARGO_FORK_AUTO_UPDATE
# `cargo flux --version` reaches cargo-flux as `flux --version`.
case "${1:-} ${2:-}" in
--version* | -V* | "flux --version" | "flux -V") ;;
*)
    if ! command -v rustup >/dev/null 2>&1; then
        echo "flux-toolchain: Flux runs on the Rust $toolchain toolchain, and rustup, which supplies it, is not on the PATH: install it from https://rustup.rs" >&2
        exit 1
    fi
    if ! rustup component list --installed --toolchain "$toolchain" 2>/dev/null | grep -q '^rustc-dev'; then
        echo "flux-toolchain: adding the Rust $toolchain toolchain Flux was built with" >&2
        rustup toolchain install "$toolchain" --profile minimal \
            --component rust-src,rustc-dev,llvm-tools >&2 || exit 1
    fi
    ;;
esac
exec "$libexec/bin/$(basename "$0")" "$@"
