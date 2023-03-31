#!/bin/bash

export BENCHMARK_NAME=sort-8.16
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.8 0.8"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

export BENCHMARK_CFLAGS="-lpthread"

function clean() {
  rm -rf $LOG file temp* gt-*
  return 0
}

function run() {
  timeout -k 0.4 0.4 $REDUCED_BIN $1 $input >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  $ORIGIN_BIN $1 $input >&temp2
  diff -q $LOG temp2 || true
}

function run_disaster() {
  timeout -k 0.5 0.5 $REDUCED_BIN $1 $input >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -E -q "$2" || true
}

function desired() {
  for input in $(ls input/*); do
    run "" || true
    run "-r" || true
    run "-s" || true
    run "-u" || true
    run "-z" || true
  done
  return 0
}

function desired_disaster() {
  case $1 in
  memory)
    MESSAGE="memory exhausted"
    ;;
  file)
    MESSAGE="Bad file descriptor|write error"
    ;;
  *)
    return 1
    ;;
  esac
  for input in $(ls input/*); do
    run_disaster "" "$MESSAGE" || true
    run_disaster "-r" "$MESSAGE" || true
    run_disaster "-s" "$MESSAGE" || true
    run_disaster "-u" "$MESSAGE" || true
    run_disaster "-z" "$MESSAGE" || true
  done
  return 0
}

function infinite() {
  r=$1
  grep "Sanitizer" $LOG >&/dev/null && return 0
  if [[ $r -eq 124 ]]; then # timeout
    return 0
  fi
  return 1
}

function outputcheckerror() {
  r="$1"
  if grep -E -q "$r" $LOG; then
    return 1
  fi
  return 0
}

OPT=("-b" "-d" "-f" "-g" "-i" "-M" "-h" "-n" "-V" "-c" "-C"
  "-k" "-m" "-o" "-S" "-t" "-T" "--help")
function undesired() {
  { timeout -k 0.1 0.1 $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  infinite $? || true
  export srcdir=$BENCHMARK_HOME/tests
  export PATH="$(pwd):$PATH"
  touch file

  for opt in ${OPT[@]}; do
    if [[ $opt == '-o' || $opt == '-T' ]]; then
      { timeout -k 0.1 0.1 $REDUCED_BIN $opt file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
      infinite $? || true
    else
      { timeout -k 0.5 0.5 $REDUCED_BIN $opt file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    fi
    crash $? && true
  done

  for opt in ${OPT[@]}; do
    if [[ $opt == "-k" ]]; then
      { timeout -k 0.1 0.1 $REDUCED_BIN $opt notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
      err=$?
      outputcheckerror "invalid number at field start: invalid count at start of \‘notexist\’" && true
      crash $err && true
    elif [[ $opt == '-T' || $opt == '--help' ]]; then
      continue
    elif [[ $opt == '-o' ]]; then
      err=$?
      crash $err && true
    elif [[ $opt == '-S' ]]; then
      { timeout -k 0.1 0.1 $REDUCED_BIN $opt notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
      err=$?
      outputcheckerror "invalid -S argument 'notexist'" && true
      crash $err && true
    elif [[ $opt == '-t' ]]; then
      { timeout -k 0.1 0.1 $REDUCED_BIN $opt notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
      err=$?
      outputcheckerror "multi-character tab \‘notexist\’" && true
      crash $err && true
    else
      { timeout -k 0.1 0.1 $REDUCED_BIN $opt notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
      err=$?
      outputcheckerror "open failed: notexist: No such file or directory" && true
      crash $err && true
    fi
  done
  for t in $(find tests/ -maxdepth 1 -perm -100 -type f); do
    { timeout -k 1 1 $t; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    crash $? && true
  done
  return 0
}

main
