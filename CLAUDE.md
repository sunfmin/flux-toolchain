# flux-toolchain

Every day, this repo builds everything Flux (https://github.com/flux-rs/flux)
needs to check a Rust crate, and publishes it as one Homebrew formula,
`sunfmin/tap/flux-toolchain`. Felix's projects install Flux only from there
(control ADR 0011). Read `GLOSSARY.md` and `docs/adr/` before working on a
ticket, and use their words.

- **Always the newest.** Nothing is pinned: each build takes Flux's `main`
  as it is that day, liquid-fixpoint's `nightly` release and z3's latest
  release. When something breaks, it is fixed then.
- **One version a day, only on change.** The daily build reads what it would
  use (Flux's commit, the fixpoint nightly's commit, the z3 release, the Rust
  nightly Flux names). When that equals what the last version used, it
  publishes nothing. Otherwise it builds and publishes one version, named by
  the UTC date: `YYYY.MM.DD`.
- **Where it runs.** GitHub Actions in this repo, on Apple silicon macOS.
  This repo is public, so Actions are free (control ADR 0001 keeps them off
  private repos only). It needs no secret: the release is this repo's, and the
  tap fetches the formula itself.
- **Prefix-free.** The formula works under any Homebrew prefix
  (`~/homebrew` as well as `/opt/homebrew`), so what it installs is
  prebuilt files placed by `install`, never a Homebrew bottle.
- Run `./gate.sh` before opening or updating a PR.

## Agent skills

### Issue tracker

Issues and specs live as GitHub issues in this checkout's tracker, which its host names (via the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage labels, each named after its role: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
