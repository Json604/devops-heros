#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python -m compileall -q app
mkdir -p build
tar -czf build/calculator.tar.gz app --exclude='__pycache__' 2>/dev/null || tar --exclude='__pycache__' -czf build/calculator.tar.gz app
