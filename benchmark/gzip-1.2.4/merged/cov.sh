#!/bin/bash

export BENCHMARK_NAME=gzip-1.2.4
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.5 0.5"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -rf $LOG *.gz *.rb2 *.tst log* foo* bar* failures_compile failures_core
  return 0
}

function desired() {
  # -c
  $ORIGIN_BIN -c <references/sample1.ref >sample1.gz 2>/dev/null
  { timeout $TIMEOUT $REDUCED_BIN -c <references/sample1.ref >sample1.rb2; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  cmp sample1.gz sample1.rb2 >&/dev/null || true
  # -d
  { timeout $TIMEOUT $REDUCED_BIN -d <sample1.gz >sample1.tst; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  cmp sample1.tst references/sample1.ref >&/dev/null || true
  # -f
  echo "1234" >foo
  $ORIGIN_BIN -c foo >&/dev/null
  { timeout $TIMEOUT $REDUCED_BIN -f foo; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  # -t (expected to return 1)
  echo "1234" >foo
  { timeout $TIMEOUT $REDUCED_BIN -t foo; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  if [[ $? -ne 1 ]]; then
    true
  fi
  # -t
  { timeout $TIMEOUT $REDUCED_BIN -t sample1.gz; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  return 0
}

function disired_disaster_mem() {
  # -d
  $ORIGIN_BIN -c <references/sample1.ref >sample1.gz 2>/dev/null
  { timeout $TIMEOUT $REDUCED_BIN -d <sample1.gz >sample1.tst; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true
  # -t
  { timeout $TIMEOUT $REDUCED_BIN -t sample1.gz; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true
  return 0
}

function disired_disaster_file() {
  # -d
  $ORIGIN_BIN -c <references/sample1.ref >sample1.gz 2>/dev/null
  { timeout $TIMEOUT $REDUCED_BIN -d <sample1.gz >sample1.tst; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true
  return 0
}

OPT0=("-l" "--list")
OPT1=("--help" "-h" "-S" "--suffix" "-k")
OPT2=("--license" "-L")
OPT3=("--no-name" "--name" "--quiet" "-r" "--recursive" "--verbose" "-q" "-v"
  "-n" "-N" "-1" "-9" "--fast" "--best")
OPT4=("--version" "-V")
function undesired() {
  { timeout $TIMEOUT $REDUCED_BIN notexist 2>$LOG; }
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true

  { timeout $TIMEOUT $REDUCED_BIN 2>$LOG; }
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true

  # keeping the error message in the following cases:
  for opt in ${OPT1[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN $opt; } &>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    cat $LOG | tail -n 17 &>log2
    diff -q references/side1 log2 >&/dev/null || true
    rm -rf log*
  done

  for opt in ${OPT2[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN $opt; } &>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    cat $LOG | tail -n 14 &>log2
    diff -q references/side2 log2 >&/dev/null || true
    rm -rf log*
  done

  for opt in ${OPT3[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN $opt; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    diff -q references/side3 $LOG >&/dev/null || true
    rm -rf log*
  done

  for opt in ${OPT4[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN $opt; } &>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    diff -q references/side4 $LOG >&/dev/null || true
    rm -rf log*
  done

  echo "1234" >foo
  $ORIGIN_BIN -c <foo >foo.gz 2>/dev/null
  for opt in ${OPT0[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN -d $opt <foo.gz >sample1.tst; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    { timeout $TIMEOUT $REDUCED_BIN -c $opt <references/sample1.ref >sample1.rb2; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    crash $? && true
  done

  echo "1234" >bar
  $ORIGIN_BIN -c <bar >bar.gz 2>/dev/null
  for opt in ${OPT3[@]}; do
    { timeout $TIMEOUT $REDUCED_BIN -d $opt <bar.gz >sample1.tst; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    { timeout $TIMEOUT $REDUCED_BIN -c $opt <references/sample1.ref >sample1.rb2; } 2>$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    crash $? && true
  done
  return 0
}

function desired_disaster() {
  case $1 in
  memory)
    MESSAGE="out of memory"
    disired_disaster_mem "$MESSAGE" || true
    ;;
  file)
    MESSAGE="Bad file descriptor"
    disired_disaster_file "$MESSAGE" || true
    ;;
  *)
    return 1
    ;;
  esac
  return 0
}

main
