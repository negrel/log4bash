#!/usr/bin/env bash

set -uo pipefail

tmpfile=$(mktemp)
trap cleanup EXIT

function cleanup {
  local exit_code="$?"
  rm -f "$tmpfile"
  exit $exit_code
}

source ./lib.sh

function line_count {
  wc -l | cut -d ' ' -f 1
}

# remove colors
unset _log_level_color
declare -A _log_level_color

i=7
for level in "trace" "debug" "info" "warn" "error" "fatal" "panic" "disabled"; do
  echo "testing logs at $level level..."
  LOG_LEVEL=$level
  log_trace "trace log" >> $tmpfile 2>&1
  log_debug "debug level" >> $tmpfile 2>&1
  log_info "info level" >> $tmpfile 2>&1
  log_warn "warn level" >> $tmpfile 2>&1
  log_error "error level" >> $tmpfile 2>&1
  $(log_fatal "fatal level" >> $tmpfile 2>&1)
  $(log_panic "panic level" >> $tmpfile 2>&1)

  lc=$(cat $tmpfile | egrep '^[0-9]+' | line_count)
  if [ $lc -eq $i ]; then
    echo "log levels at $level level OK"
  else
    echo "missing log(s) at $level level: expected $i, got $lc"
    exit 1
  fi

  # Truncate file
  > $tmpfile
  ((i=i-1))
done

log "not a level"
