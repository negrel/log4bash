#!/usr/bin/env bash

set -uo pipefail

tmpfile=$(mktemp)
LOG_OUTPUT="$tmpfile"
trap cleanup EXIT

cleanup() {
	local exit_code="$?"
	rm -f "$tmpfile"
	exit $exit_code
}

source ./lib.sh

line_count() {
	wc -l | cut -d ' ' -f 1
}

# remove colors
unset _log_level_color
declare -A _log_level_color

i=7
for level in "trace" "debug" "info" "warn" "error" "fatal" "panic" "disabled"; do
	echo "testing logs at $level level..."
	LOG_LEVEL=$level
	log_trace "trace level"
	log_debug "debug level"
	log_info "info level"
	log_warn "warn level"
	log_error "error level"
	$(log_fatal "fatal level" &>/dev/null)
	$(log_panic "panic level" &>/dev/null)

	lc=$(cat "$tmpfile" | grep -E '^[0-9]+' | line_count)
	if [ $lc -eq $i ]; then
		echo "logs at $level level: OK"
	else
		echo "missing log(s) at $level level: expected $i, got $lc"
		exit 1
	fi

	# Truncate file
	> "$tmpfile"
	((i=i-1))
done

echo "testing log without level..."
LOG_LEVEL="info"
LOG_LEVEL_DEFAULT="error"

# Truncate file
> "$tmpfile"
log "not a level"
fgrep "[error] - not a level" $tmpfile &>/dev/null
if [ "$?" = "0" ]; then
  echo "log without level OK"
else
  echo "log without level KO"
  exit 1
fi
