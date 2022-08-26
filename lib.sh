#!/usr/bin/env bash

# Log level
: ${LOG_LEVEL="info"}
# Default log level if unspecified while
# calling log functions
: ${LOG_LEVEL_DEFAULT="info"}
# Log output file
: ${LOG_OUTPUT="/dev/stderr"}
# prefix function called for each log
: ${LOG_PREFIX="log_prefix"}
# Exit code used by log at fatal level
: ${LOG_FATAL_EXIT_CODE="1"}

# Log levels
declare -A _log_level
_log_level["disabled"]=0
_log_level["panic"]=1
_log_level["fatal"]=2
_log_level["error"]=3
_log_level["warn"]=4
_log_level["info"]=5
_log_level["debug"]=6
_log_level["trace"]=7

# ANSI color code
declare -A _log_color
_log_color["white"]="30"
_log_color["blue"]="34"
_log_color["green"]="32"
_log_color["yellow"]="33"
_log_color["red"]="31"

# Color per log level
declare -A _log_level_color
_log_level_color["trace"]="blue"
_log_level_color["debug"]="blue"
_log_level_color["info"]="green"
_log_level_color["warn"]="yellow"
_log_level_color["error"]="red"
_log_level_color["fatal"]="red"
_log_level_color["panic"]="red"

function log {
  local level="${_log_level[${1="$LOG_LEVEL_DEFAULT"}]}"
  if [ -z "$level" ]; then
    level=5
  fi
  
  # Skip log above level
  if [ $level -gt ${_log_level[$LOG_LEVEL]} ]; then
    return 0
  fi

  # Detect pipe
  if [ "$#" -le 1 ]; then
    log_pipe "$@"
  else
    _log "$@"
  fi
}

function log_pipe {
  while IFS= read -r line; do
    _log "$1" "$line"
  done
}

function _log {
  # Detect errexit
  local errexit="n"
  if [[ "$-" == *e* ]]; then 
    set +e
    errexit="y"
  fi

  local prefix;
  prefix="$($LOG_PREFIX "$@")"
  shift $?

  printf "%s %s\n" "$prefix" "$*" >"$LOG_OUTPUT"

  # Restitute errexit
  test "$errexit" = "y" && set -e
}

function log_prefix {
  local date="$(date -Iseconds)"
  local level="${1:-"$LOG_LEVEL_DEFAULT"}"
  local level_color="${_log_level_color[$level]:-}"

  local color=""
  local end_color=""
  if [ -n "$level_color" ]; then
    color="\033[${_log_color[$level_color]:-0}m"
    end_color="\033[0m"
  fi

  printf "${color}$date [$level] -$end_color"

  # We return one as we consumed one parameter
  return 1
}

function log_trace {
  log "trace" "$@"
}

function log_debug {
  log "debug" "$@"
}

function log_info {
  log "info" "$@"
}

function log_warn {
  log "warn" "$@"
}

function log_error {
  log "error" "$@"
}

function log_fatal {
  log "fatal" "$*"
  exit $LOG_FATAL_EXIT_CODE
}

function log_panic {
  log "panic" "$*"
  _stacktrace
  exit 1
}

function _stacktrace {
  local frame=0 LINE SUB FILE
  while read LINE SUB FILE < <(caller "$frame"); do
    printf "\t\033[${_log_color[red]}m%s()\n\t\t%s:%s\033[0m\n" "$SUB" "$FILE" "$LINE" 1>&2
    ((frame++))
  done
}