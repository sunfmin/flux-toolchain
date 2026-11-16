# cargo flux runs huacnlee/cargo

Status: accepted (2026-11-15)

## Context

[huacnlee/cargo](https://huacnlee.github.io/cargo/) is a drop-in fork of Cargo. It builds each project into `~/.cargo/targets/<name>-<hash>`, builds registry and git dependencies once in `~/.cargo/targets/shared-deps` for every project and worktree, and cleans up after itself. Projects checked with Flux run `cargo flux` in many worktrees, and each one built `flux-rs` and its dependencies again.

Felix, 2026-11-15 (quoted in [sunfmin/control#1124](https://github.com/sunfmin/control/issues/1124)): 「我那个 Rust tool Chain 项目。 那把这个也默认用上。 https://huacnlee.github.io/cargo/」

## Decision

- The tarball carries huacnlee/cargo's newest release, repackaged like z3, as `libexec/bin/cargo`, checked against the release's `SHA256SUMS`. Its tag is the input `cargo`, so a new release makes a new version.
- The `cargo-flux` and `flux` wrappers put `libexec/bin` first on the PATH, so the `cargo +<nightly>` that cargo-flux runs is huacnlee/cargo. The wrappers set `CARGO_FORK_AUTO_UPDATE=0`: the formula decides which version runs.
- The wrappers set `__CARGO_TEMPORARY_FINE_GRAIN_LOCKING_OPT_OUT=1`. huacnlee/cargo turns on `-Zfine-grain-locking` by default: each build holds shared locks on every unit until it exits and waits blocking for an exclusive lock on each unit it must rebuild, so concurrent `cargo flux` runs sharing `shared-deps` deadlock at 0% CPU in `flock` ([sunfmin/control#1249](https://github.com/sunfmin/control/issues/1249)). Without it they serialise on the build-dir lock and finish. Felix, 2026-11-17: 「把 fine grained locking 去掉……还是用原来的通过配置把这种 lock 直接 disable 掉吧」
- huacnlee/cargo passes `-Zthreads=8` to rustc on nightly, and Flux's driver panics under it (`retrieve_mir_body`). `libexec/sysroot/flux-driver` is a small binary (`scripts/driver-shim.c`) that drops `-Zthreads=*` and runs Flux's driver, `flux-driver-real`. It is a binary because macOS strips the `DYLD_*` variables rustup sets from `/bin/sh` scripts. It also keeps Flux working on machines whose own `cargo` is huacnlee/cargo.
- `scripts/smoke.sh` fails unless `cargo flux` built through the shipped cargo (`~/.cargo/targets/smoke-*` exists).
- Only `cargo flux` runs it. What `cargo` is elsewhere on the machine is not this formula's business.

## Consequences

- On Studio64, the smoke crate checked in 1.66 s with `flux-rs` reused from `shared-deps`, against 29–57 s through rustup's cargo.
- huacnlee/cargo ignores `--target-dir`, `CARGO_TARGET_DIR` and `build.target-dir` under `cargo flux`.
- When huacnlee/cargo stops passing `-Zthreads`, or Flux's driver works under it, remove the shim.
