#!/bin/bash

export BENCHMARK_NAME=rm-8.4
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.5 0.5"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -rf $LOG dir file
  chmod -Rf 755 cu-*
  /bin/rm -rf cu-*
  return 0
}

function run1() {
  touch file
  { timeout $TIMEOUT $REDUCED_BIN file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  a=1
  b=1
  if [[ $r -eq 0 && ! -f file ]]; then
    a=0
  fi
  /bin/rm -rf file
  { timeout $TIMEOUT $REDUCED_BIN file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  err=1
  if grep -q "No such file or directory" $LOG; then
    err=0
  fi
  if [[ $r -eq 1 && $err -eq 0 ]]; then
    b=0
  fi
  if [[ $a -eq 0 && $b -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

function run1_disaster() {
  touch file
  { timeout $TIMEOUT $REDUCED_BIN file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -q -E $1 || true
  return 0
}

function run2() {
  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -r dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  a=1
  b=1
  if [[ $r -eq 0 && ! -d dir ]]; then
    a=0
  fi
  /bin/rm -rf dir
  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -r -f dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  if [[ $r -eq 0 && ! -d dir ]]; then
    b=0
  fi
  /bin/rm -rf dir
  if [[ $a -eq 0 && $b -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

function run2_disaster() {
  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -r dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  /bin/rm -rf dir
  cat $LOG | grep -q -E $1 || true

  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -r -f dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  /bin/rm -rf dir
  cat $LOG | grep -q -E $1 || true

  return 0
}

function run3() {
  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -f dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  x=1
  if grep -q "cannot remove \`dir': Is a directory" $LOG; then
    x=0
  fi
  if [[ $r -eq 1 && $x -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

function run3_disaster() {
  mkdir dir
  { timeout $TIMEOUT $REDUCED_BIN -f dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -q -E $1 || true
  return 0
}

function run4() {
  touch filei
  { timeout $TIMEOUT echo "Y" | timeout $TIMEOUT $REDUCED_BIN -i filei; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  if [[ $r -eq 0 && ! -f filei ]]; then
    return 0
  else
    clean
    return 1
  fi
  touch filei
  { timeout $TIMEOUT echo "N" | timeout $TIMEOUT $REDUCED_BIN -i filei; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  r=$?
  if [[ $r -eq 0 && -f filei ]]; then
    return 0
  else
    clean
    return 1
  fi
  rm filei
}

function run4_disaster() {
  touch filei
  { timeout $TIMEOUT echo "Y" | timeout $TIMEOUT $REDUCED_BIN -i filei; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -q -E $1 || true

  touch filei
  { timeout $TIMEOUT echo "N" | timeout $TIMEOUT $REDUCED_BIN -i filei; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -q -E $1 || true

  return 0
}

# Desired Options: -r, -f, -i
function desired() {
  run1 || true
  /bin/rm -rf file dir
  run2 || true
  /bin/rm -rf file dir
  run3 || true
  /bin/rm -rf file dir
  run4 || true
  /bin/rm -rf file dir
}

function desired_disaster() {
  case $1 in
  memory)
    MESSAGE="memory exhausted"
    ;;
  file)
    MESSAGE="write error"
    ;;
  *)
    return 1
    ;;
  esac
  /bin/rm -rf file dir
  run2_disaster $1 "$MESSAGE" || true
  /bin/rm -rf file dir
  run3_disaster $1 "$MESSAGE" || true
  /bin/rm -rf file dir
  run4_disaster $1 "$MESSAGE" || true
  /bin/rm -rf file dir
}

function outputcheckerror() {
  r="$1"
  if grep -q -E "$r" $LOG; then
    return 1
  fi
  return 0
}

function undesired() {
  export srcdir=$BENCHMARK_HOME/benchmark/
  export PATH="$(pwd):$PATH"
  { timeout $TIMEOUT $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "missing operand" && true
  crash $err && true
  for t in $(ls tests/*); do
    { timeout $TIMEOUT $t; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    r=$?
    crash $r && true
  done
  return 0
}

main
