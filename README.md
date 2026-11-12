# flux-toolchain

Daily macOS (Apple silicon) builds of the toolchain that
[Flux](https://github.com/flux-rs/flux), the refinement type checker for
Rust, needs: `cargo-flux`, `flux`, the Flux sysroot,
[liquid-fixpoint](https://github.com/ucsd-progsys/liquid-fixpoint)'s
`fixpoint` and [z3](https://github.com/Z3Prover/z3).

```sh
brew install sunfmin/tap/flux-toolchain
```

Each build takes the newest of everything: Flux's `main`, liquid-fixpoint's
nightly, z3's latest release. A day whose inputs changed gets one version,
named by its date; a day with no change gets none.

Flux's driver links against the Rust nightly it was built with, so
[rustup](https://rustup.rs) must be installed; the formula says which
toolchain to add.
