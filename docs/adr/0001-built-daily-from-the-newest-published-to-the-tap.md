# The Flux toolchain is built daily from the newest inputs and published to sunfmin/tap

Status: accepted (2026-11-12)

## Context

Projects that check Rust with [Flux](https://github.com/flux-rs/flux) need `cargo-flux`, `flux`, the Flux sysroot, liquid-fixpoint's `fixpoint` and `z3`. Building them from source on each machine meant a GHC download and a full liquid-fixpoint build through stack, plus a cargo-flux build. Each new machine paid this once, and each pin change paid it again. On Studio64 on 2026-11-12, the three tools took 732 seconds to install.

Felix, 2026-11-12 (quoted in [sunfmin/control#771](https://github.com/sunfmin/control/issues/771)): 「每次 liquid fix point 都要自己编译是不对的」, 「这个不要盯了，每次都用最新的。出问题的话再改」, 「每天把这个工具链所需要的所有的东西都编译成 homebrew 我的 tap 下发布，我以后所有的项目都在这 tap 下安装。安装最新版。每天如果有变化的话，就一个版本」.

## Decision

- This public repo builds the toolchain (`cargo-flux`, `flux`, the Flux sysroot, `fixpoint`, `z3`) daily in GitHub Actions and publishes it as the Homebrew formula `sunfmin/tap/flux-toolchain`. Actions cost nothing on a public repo.
- Every build takes the newest inputs: Flux's `main`, liquid-fixpoint's `nightly` release and z3's latest release. Nothing is pinned. When the inputs equal the last version's, nothing is published. When they change, one version is published, named by the UTC date `YYYY.MM.DD`, at most one a day.
- Flux has no release artifacts, so it is built from source here. `fixpoint` and `z3` are upstream's own binaries, repackaged. Before each version is published, `cargo flux` runs on a tiny crate: the correct one must pass and the broken one must be rejected.
- Projects that need Flux install it with `brew install sunfmin/tap/flux-toolchain` and upgrade with `brew upgrade`. No project pins tool versions or builds the tools itself. If something breaks, fix it then.
- After publishing a release, CI pushes the formula straight into the tap's `Formula/` (Felix: 「CI 跑完直接推到我的 tap 里。不要去拉」). The push uses the deploy key `TAP_DEPLOY_KEY`, which can write only sunfmin/homebrew-tap.
- No afkconvoy fleet works this repo, and it has no afkconvoy config: it is one workflow and a few scripts.

## Considered options

- **The tap pulls the newest formula on a schedule.** It needs no credential, but a release could take up to 3 hours to reach the tap. Felix does not want a pull. Not chosen.

## Consequences

- Each project's side of this decision is in its own ADR. afkconvoy: [docs/adr/0067](https://github.com/sunfmin/afkconvoy/blob/main/docs/adr/0067-flux-comes-from-the-tap-newest-daily.md). Its `verify.sh` installs from the tap and pins nothing.
- A project's `flux-rs` dependency by rev can drift from the tap's daily Flux. When that breaks a gate, move the rev to the commit the formula's caveats name.
- Flux's driver links the Rust nightly it was built with. The `cargo-flux` and `flux` wrappers install that nightly through rustup on first run, so every machine needs rustup.
- Only Apple silicon macOS builds are published.
