#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PYTHON_BIN=${PYTHON_BIN:-python3}
"$PYTHON_BIN" -m compileall -q app
mkdir -p build
tar --exclude='__pycache__' -czf build/calculator.tar.gz app
