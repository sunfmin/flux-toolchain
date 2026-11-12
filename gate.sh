#!/bin/sh
# The gate: what must pass before anything lands. docs/agents/afkconvoy.md
# names it, run through `afkconvoy exclusive`. By hand:
# `afkconvoy exclusive -- ./gate.sh`.
#
# It checks what this repo holds today, with tools every Mac has:
#   - each shell script parses (sh -n, or bash -n for a bash shebang)
#   - each Ruby file, the formula template among them, parses (ruby -c)
#   - each YAML file, the workflows among them, parses
# A check for a new kind of file is added here with the first such file.
set -e
cd "$(dirname "$0")"
echo "gate: on $(hostname), commit $(git rev-parse HEAD)" >&2
failed=
files=$(git ls-files)
for f in $files; do
    case "$f" in
    *.sh)
        case "$(head -1 "$f")" in
        *bash*) bash -n "$f" || failed="$failed $f" ;;
        *) sh -n "$f" || failed="$failed $f" ;;
        esac
        ;;
    *.rb | *.rb.tmpl)
        ruby -c "$f" >/dev/null || failed="$failed $f"
        ;;
    *.yml | *.yaml)
        ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]), aliases: true)' "$f" || failed="$failed $f"
        ;;
    esac
done
if [ -n "$failed" ]; then
    echo "gate: these do not parse:$failed" >&2
    exit 1
fi
echo "gate: green" >&2
