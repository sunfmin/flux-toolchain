# flux-toolchain

Daily macOS (Apple silicon) builds of the toolchain that
[Flux](https://github.com/flux-rs/flux), the refinement type checker for
Rust, needs: `cargo-flux`, `flux`, the Flux sysroot,
[liquid-fixpoint](https://github.com/ucsd-progsys/liquid-fixpoint)'s
`fixpoint` and [z3](https://github.com/Z3Prover/z3).

```sh
brew install sunfmin/tap/flux-toolchain
```

- **Always the newest.** Each build takes Flux's `main`, liquid-fixpoint's
  `nightly` release and z3's latest release. Nothing is pinned.
- **One version a day, only on change.** `.github/workflows/daily.yml` runs
  every day at 02:23 UTC. When the inputs (`scripts/inputs.sh`) equal the last
  version's, it publishes nothing; otherwise it builds (`scripts/build.sh`),
  runs `cargo flux` on a tiny crate that must pass and a broken one that must
  fail (`scripts/smoke.sh`), and publishes a release named by the UTC date,
  `YYYY.MM.DD`, holding the tarball, `inputs.json` and the formula
  (`scripts/formula.sh`). `latest.json` records the newest version.
- **The tap** (sunfmin/homebrew-tap) copies the newest release's
  `flux-toolchain.rb` into `Formula/` on its own schedule, so this repo
  needs no token for it.
- **Any Homebrew prefix.** The formula places prebuilt files; it installs no
  bottle, so it works under `~/homebrew` as well as `/opt/homebrew`.

Flux's driver links against the Rust nightly it was built with. The
`cargo-flux` and `flux` wrappers add that toolchain through
[rustup](https://rustup.rs) on first run, and put the shipped `fixpoint`, `z3`
and sysroot in front. A crate checked with Flux depends on `flux-rs` at the
commit the formula's caveats name.

Flux itself publishes no binaries, so it is built here; `fixpoint` and `z3`
are upstream's own release binaries, repackaged.
