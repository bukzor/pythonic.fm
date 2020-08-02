#!/bin/bash
# Create a shell (or run a command) with Formality installed and  active.
# See https://github.com/moonad/Formality/
if [[ "$-" == *i* ]]; then
  exec >&2
  echo "error: This script must not be sourced: $0"
  exit 1
fi

set -euo pipefail
HERE="$(readlink -f "$(dirname "$0")")"
FORMALITY_HOME="${FORMALITY_HOME:-$PWD/Formality}"

export PATH="$PWD/Formality/node_modules/.bin:$PATH"
export PS1="$(
  grep -az '^PS1=.*$' /proc/$PPID/environ |
    tr -d '\0' |
    sed 's/^PS1=//; $ s/^/(Formality) /' \
  ;
)"

if ! [ -d "$FORMALITY_HOME" ]; then
  git clone https://github.com/moonad/Formality.git "$FORMALITY_HOME"
fi

cd "$FORMALITY_HOME"
"$HERE/brew" install yarn
set +x
eval "$("$HERE/brew" shellenv)"
yarn add ./javascript
cd -

if [[ "$@" ]]; then
  exec "$@"
else
  exec bash --norc
fi
