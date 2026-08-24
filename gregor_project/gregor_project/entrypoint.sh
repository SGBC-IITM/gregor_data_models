#!/usr/bin/env sh
set -eu

chown -R appuser:appuser /app/gregor_project

exec gosu appuser "$@"
