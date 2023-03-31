#!/bin/bash

export BENCHMARK_NAME=uniq-8.16
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.5 0.5"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -rf $LOG temp
  return 0
}

# $1: option
function desired_run() {
  temp1=$({ timeout $TIMEOUT $REDUCED_BIN $1 data.txt; } 2>&1 || true)
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  temp2=$({ $ORIGIN_BIN $1 data.txt; } 2>&1)
  diff -q <(echo $temp1) <(echo $temp2) >&/dev/null || true
  temp1=$({ timeout $TIMEOUT $REDUCED_BIN $1 input; } 2>&1 || true)
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  temp2=$({ $ORIGIN_BIN $1 input; })
  diff -q <(echo $temp1) <(echo $temp2) >&/dev/null || true
  return 0
}

function desired() {
  desired_run "" || true
  desired_run "-c" || true
  desired_run "-d" || true
  desired_run "-u" || true
  desired_run "-i" || true
  desired_run "-f 5" || true
  desired_run "-s 10" || true
  desired_run "-w 10" || true
  return 0
}

function desired_disaster_run() {
  { timeout $TIMEOUT $REDUCED_BIN $1 data.txt; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -E -q "$2" $LOG || true
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
  desired_disaster_run "" "$MESSAGE" || true
  desired_disaster_run "-c" "$MESSAGE" || true
  desired_disaster_run "-d" "$MESSAGE" || true
  desired_disaster_run "-u" "$MESSAGE" || true
  desired_disaster_run "-i" "$MESSAGE" || true
  desired_disaster_run "-f 5" "$MESSAGE" || true
  desired_disaster_run "-s 10" "$MESSAGE" || true
  desired_disaster_run "-w 10" "$MESSAGE" || true
  return 0
}

function infinite() {
  if [[ $? -eq 124 ]]; then # timeout
    return 0
  else
    return 1
  fi
}

function outputcheckerror() {
  r="$1"
  if [[ $3 == "" && -s temp ]]; then
    return 1
  fi
  if grep -E -q "$r" $LOG; then
    return 1
  fi
  return 0
}

function run() {
  printf $2 >&temp
  { timeout $TIMEOUT $REDUCED_BIN "$1" temp; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "$3" && true
  crash $err && true
  return 0
}

function undesired() {
  { timeout $TIMEOUT $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  infinite $? || true
  { timeout $TIMEOUT $REDUCED_BIN notexist; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "notexist: No such file or directory" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN notexist1 notexist2 notexist3; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "extra operand" && true
  crash $err && true
  run '-f1' "y z\n\xa0 y z\n" "" || true
  run '' '' "No such file or directory" || true
  run '' "a\na\n" "No such file or directory" || true
  run '' "a\na" "No such file or directory" || true
  run '' "a\nb" "No such file or directory" || true
  run '' "a\na\nb" "No such file or directory" || true
  run '' "b\na\na\n" "No such file or directory" || true
  run '' "a\nb\nc\n" "No such file or directory" || true
  run '-z' "a\na\n" "" || true
  run '-z' "a\na" "" || true
  run '-z' "a\nb" "" || true
  run '-z' "a\na\nb" "" || true
  run '-dz' "a\na\n" "" || true
  run '' "ö\nv\n" "No such file or directory" || true
  run '-u' "a\na\n" "No such file or directory" || true
  run '-u' "a\nb\n" "" || true
  run '-u' "a\nb\na\n" "" || true
  run '-u' "a\na\n" "" || true
  run '-u' "a\na\n" "" || true
  run '-d' "a\na\n" "" || true
  run '-d' "a\nb\n" "" || true
  run '-d' "a\nb\na\n" "" || true
  run '-d' "a\na\nb\n" "" || true
  run '-1' "a a\nb a\n" || true
  run "-f 1" "a a\nb a\n" || true
  run "-f 1" "a a\nb b\n" || true
  run "-f 1" "a a a\nb a c\n" || true
  run "-f 1" "b a\na a\n" || true
  run "-f 2" "a a c\nb a c\n" || true
  run '+1' "aaa\naaa\n" "+1: No such file or directory" || true
  run '+1' "baa\naaa\n" "+1: No such file or directory" || true
  run "-s 1" "aaa\naaa\n" "" || true
  run "-s 2" "baa\naaa\n" "" || true
  run "+1 --" "aaa\naaa\n" "+1 --: No such file or directory" || true
  run "+1 --" "baa\naaa\n" "+1 --: No such file or directory" || true
  run "-f 1 -s 1" "a aaa\nb ab\n" "1 -s 1: invalid number of fields to skip" || true
  run "-f 1 -s 1" "a aaa\nb aaa\n" "1 -s 1: invalid number of fields to skip" || true
  run "-s 1 -f 1" "a aaa\nb ab\n" "1 -f 1: invalid number of fields to skip" || true
  run "-s 1 -f 1" "a aaa\nb aaa\n" "1 -s 1: invalid number of fields to skip" || true
  run "-s 4" "abc\nabcd\n" || true
  run "-s 0" "abc\nabcd\n" || true
  run "-s 0" "abc\n" || true
  run "-w 0" "abc\nabcd\n" || true
  run "-w 1" "a a\nb a\n" || true
  run "-w 3" "a a\nb a\n" || true
  run "-w 1 -f 1" "a a a\nb a c\n" "1 -f 1: invalid number of bytes to compare" || true
  run "-f 1 -w 1" "a a a\nb a c\n" "1 -w 1: invalid number of fields to skip" || true
  run "-f 1 -w 4" "a a a\nb a c\n" "1 -w 4: invalid number of fields to skip" || true
  run "-f 1 -w 3" "a a a\nb a c\n" "1 -w 3: invalid number of fields to skip" || true
  run '' "a\0a\na\n" "No such file or directory" || true
  run '' "a\ta\na a\n" "No such file or directory" || true
  run "-f 1" "a\ta\na a\n" || true
  run "-f 2" "a\ta a\na a a\n" || true
  run "-f 1" "a\ta\na\ta\n" || true
  run '-c' "a\nb\n" || true
  run '-c' "a\na\n" || true
  run '-D' "a\na\n" || true
  run "-D -w1" "a a\na b\n" "invalid option --" || true
  run "-D -c" "a a\na b\n" "invalid option --" || true
  run '--all-repeated=separate' "a\na\n" "" || true
  run '--all-repeated=separate' "a\na\nb\nc\nc\n" "" || true
  run '--all-repeated=separate' "a\na\nb\nb\nc\n" "" || true
  run '--all-repeated=prepend' "a\na\n" "" || true
  run '--all-repeated=prepend' "a\na\nb\nc\nc\n" "" || true
  run '--all-repeated=prepend' "a\nb\n" "" || true
  run "-d -u" "a\na\n\b" || true
  run "-d -u -w1111111111111111111111111111111111111111" "a\na\n\b" "invalid option --" || true
  run '--zero-terminated' "a\na\nb" "invalid option --" || true
  run '--zero-terminated' "a\0a\0b" "" || true
  return 0
}

main
