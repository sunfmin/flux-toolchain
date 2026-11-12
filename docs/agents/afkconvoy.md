# afkconvoy config

What `afkconvoy` reads for this repo. Its fleet works the issues labelled
`repo:sunfmin/flux-toolchain` in the tracker, sunfmin/control
(control ADR 0002). This repo names no `team`, so it is unbound.

```yaml
base_branch: main
gate_command: afkconvoy exclusive -- ./gate.sh
gate_seconds: 600
ready_label: ready-for-agent
epic_labels: [epic, prd]
escalate_label: ready-for-human
```

The gate only parses what the repo holds (`gate.sh`): the builds themselves
run in this repo's GitHub Actions, which a public repo has for free
(control ADR 0001 keeps Actions off private repos only).
