# flux-toolchain

**Toolchain**: everything `cargo flux` needs on a Mac: `cargo-flux` and
`flux`, the Flux sysroot (`flux-driver` and its precompiled libraries),
`fixpoint` (liquid-fixpoint) and `z3`, plus the Rust nightly Flux is built
against, which rustup supplies.

**Inputs**: what one build takes from upstream: Flux's `main` commit, the
commit of liquid-fixpoint's `nightly` release, z3's latest release, and the
Rust nightly in Flux's `rust-toolchain.toml`. Equal inputs make an equal
toolchain, so they decide whether a day gets a version.

**Version**: one published toolchain, named by its UTC date `YYYY.MM.DD`; a
GitHub release of this repo holding the tarball, the inputs it was built
from, and the formula that installs it.

**Tap**: sunfmin/homebrew-tap, installed as `sunfmin/tap`. It holds
`Formula/flux-toolchain.rb`, copied from the newest version's release.
_Avoid_: bottle (the formula installs no Homebrew bottle)
