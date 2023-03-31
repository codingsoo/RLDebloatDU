#!/bin/bash

export BENCHMARK_NAME=chown-8.2
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.1 0.1"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -rf $LOG d1 temp temp1 temp2 file log symfile1 symfile2
  rm -rf cu-*
  return 0
}

# $1 : option, $2 : file for reduced, $3 : file for original
function run() {
  { timeout $TIMEOUT $REDUCED_BIN $1 $(whoami):sudo $2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  ls -al $2 | cut -d ' ' -f 4 >temp1
  $ORIGIN_BIN $1 $(whoami):sudo $3 >&/dev/null
  ls -al $3 | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN $1 $(whoami):$(whoami) $2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  ls -al $2 | cut -d ' ' -f 4 >temp1
  $ORIGIN_BIN $1 $(whoami):$(whoami) $3 >&/dev/null
  ls -al $3 | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true
  return 0
}

function desired() {
  touch file1
  touch file2
  run "" file1 file2 || true
  rm -rf file1 file2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run "" d1/d1/d1/file d2/d2/d2/file || true
  rm -rf d1 d2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run "" d1 d2 || true
  ls -al d1/d1/d1/file | cut -d ' ' -f 4 >temp1
  ls -al d2/d2/d2/file | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true
  rm -rf d1 d2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run "-R" d1 d2 || true
  ls -al d1/d1/d1/file | cut -d ' ' -f 4 >temp1
  ls -al d2/d2/d2/file | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true
  rm -rf d1 d2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run "-h" file1 file2 || true
  rm -rf file1 file2 symfile1 symfile2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run "-h" symfile1 symfile2 || true
  rm -rf file1 file2 symfile1 symfile2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run "" symfile1 symfile2 || true
  rm -rf file1 file2 symfile1 symfile2

  return 0
}

function run_disaster() {
  { timeout $TIMEOUT $REDUCED_BIN $1 $(whoami):sudo $2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -E -q "$4" || true
  { timeout $TIMEOUT $REDUCED_BIN $1 $(whoami):$(whoami) $2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  cat $LOG | grep -E -q "$4" || true
  return 0
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
  touch file1
  touch file2
  run_disaster "" file1 file2 "$MESSAGE" || true
  rm -rf file1 file2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run_disaster "" d1/d1/d1/file d2/d2/d2/file "$MESSAGE" || true
  rm -rf d1 d2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run_disaster "" d1 d2 "$MESSAGE" || true
  ls -al d1/d1/d1/file | cut -d ' ' -f 4 >temp1
  ls -al d2/d2/d2/file | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true
  rm -rf d1 d2

  mkdir -p d1/d1/d1
  touch d1/d1/d1/file
  mkdir -p d2/d2/d2
  touch d2/d2/d2/file
  run_disaster "-R" d1 d2 "$MESSAGE" || true
  ls -al d1/d1/d1/file | cut -d ' ' -f 4 >temp1
  ls -al d2/d2/d2/file | cut -d ' ' -f 4 >temp2
  diff -q temp1 temp2 >&/dev/null || true
  rm -rf d1 d2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run_disaster "-h" file1 file2 "$MESSAGE" || true
  rm -rf file1 file2 symfile1 symfile2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run_disaster "-h" symfile1 symfile2 "$MESSAGE" || true
  rm -rf file1 file2 symfile1 symfile2

  touch file1
  touch file2
  ln -s file1 symfile1
  ln -s file2 symfile2
  run_disaster "" symfile1 symfile2 "$MESSAGE" || true
  rm -rf file1 file2 symfile1 symfile2

  return 0
}

function outputcheck() {
  r="$1"
  if grep -q -E "$r" $LOG; then
    return 1
  fi
  return 0
}

OPT=("" "-c" "-f" "-v" "-H" "-L" "-P")
function undesired() {
  { timeout 0.5 $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheck "missing operand" && true
  crash $err && true
  { timeout 0.5 $REDUCED_BIN input1 input2 notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheck "invalid user" && true
  crash $err && true
  { timeout 0.5 $REDUCED_BIN notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheck "missing operand after \`notexist'" && true
  crash $err && true
  export srcdir=$BENCHMARK_HOME/../
  export PATH="$(pwd):$PATH"
  touch file
  for opt in ${OPT[@]}; do
    { timeout 0.5 $REDUCED_BIN $opt file; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    err=$?
    outputcheck "missing operand after \`file'" && true
    crash $err && true
  done
  { timeout 0.5 $REDUCED_BIN --help; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  return 0
}

main
