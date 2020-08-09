#!/bin/bash
# Create a shell (or run a command) with Formality installed and  active.
# See https://github.com/moonad/Formality/
if [[ "$-" == *i* ]]; then
  exec >&2
  echo "error: This script must not be sourced: $0"
  return 1
fi

set -euo pipefail
HERE="$(readlink -f "$(dirname "$0")")"
FORMALITY_PREFIX="${FORMALITY_PREFIX:-$PWD/share}"

export PATH="$FORMALITY_PREFIX/node_modules/.bin:$PATH"
export PS1="$(
  grep -az '^PS1=.*$' /proc/$PPID/environ |
    tr -d '\0' |
    sed 's/^PS1=//; $ s/^/(Formality) /' \
  ;
)"

set -x
if ! [[ -d "$FORMALITY_PREFIX/Formality/.git" ]]; then
  git clone https://github.com/moonad/Formality.git "$FORMALITY_PREFIX/Formality"
else
  git -C "$FORMALITY_PREFIX/Formality" pull --rebase=preserve origin master
fi

if ! [[ -d "$FORMALITY_PREFIX/moonad" ]]; then
  git clone https://github.com/moonad/moonad.git "$FORMALITY_PREFIX/moonad"
else
  git -C "$FORMALITY_PREFIX/moonad" pull --rebase=preserve origin master
fi

"$HERE/brew" install yarn
set +x; eval "$(set -x; "$HERE/brew" shellenv; echo set -x)"

( cd "$FORMALITY_PREFIX"
  if ! [[ -f package.json ]]; then
    echo '{}' > package.json
  fi

  yarn add "link:$(readlink -f ./Formality/javascript)"
)

if [[ "$@" ]]; then
  exec "$@"
else
  exec bash --norc
fi
