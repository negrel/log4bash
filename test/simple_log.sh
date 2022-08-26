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

LOG_LEVEL=trace
# remove colors
unset _log_level_color
declare -A _log_level_color

echo "testing trace log..."
log_trace "trace log" > $tmpfile 2>&1
fgrep "[trace] - trace log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "trace log OK"
else
  echo "trace log absent in file"
  exit 1
fi

echo "testing debug log..."
log_debug "debug log" > $tmpfile 2>&1
fgrep "[debug] - debug log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "debug log OK"
else
  echo "debug log absent in file"
  exit 1
fi

echo "testing info log..."
log_info "info log" > $tmpfile 2>&1
fgrep "[info] - info log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "info log OK"
else
  echo "info log absent in file"
  exit 1
fi

echo "testing warn log..."
log_warn "warn log" > $tmpfile 2>&1
fgrep "[warn] - warn log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "warn log OK"
else
  echo "warn log absent in file"
  exit 1
fi

echo "testing error log..."
log_error "error log" > $tmpfile 2>&1
fgrep "[error] - error log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "error log OK"
else
  echo "error log absent in file"
  exit 1
fi

echo "testing fatal log..."
$(log_fatal "fatal log" > $tmpfile 2>&1)
fgrep "[fatal] - fatal log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "fatal log OK"
else
  echo "fatal log absent in file"
  exit 1
fi

echo "testing fatal log..."
$(log_panic "panic log" > $tmpfile 2>&1)
fgrep "[panic] - panic log" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "panic log OK"
else
  echo "panic log absent in file"
  exit 1
fi
fgrep "simple_log.sh" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
   echo "panic log stacktrace OK"
else
  echo "panic log stacktrace absent in file"
  exit 1
fi
