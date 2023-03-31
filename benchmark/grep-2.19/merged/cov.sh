#!/bin/bash

export BENCHMARK_NAME=grep-2.19
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.8 0.8"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -f $LOG file log2
  rm -rf gt-*
  rm -f lists.txt
  return 0
}

function compile() {
  if [[ $1 == "-fsanitize=memory -fsanitize-memory-use-after-dtor" ]]; then
    CFLAGS="-w $1 -lpcre"
  else
    CFLAGS="-w $1 -D __msan_unpoison(s,z) -lpcre"
  fi
  $CC $SRC -fprofile-instr-generate -fcoverage-mapping $CFLAGS -o $REDUCED_BIN >&$LOG || true
  return 0
}

function desired() {
  { timeout $TIMEOUT $REDUCED_BIN "a" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  $ORIGIN_BIN "a" input2 >&log2
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "a" -v -H -r input_dir; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "a" -v -H -r input_dir; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -h -r input_dir; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "1" -h -r input_dir; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -n "si" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -n "si" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -l; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "1" -r input_dir -l; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -L; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "1" -r input_dir -L; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "randomtext" -r input_dir -c; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "randomtext" -r input_dir -c; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -o [r][a][n][d]* input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -o [r][a][n][d]* input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -q; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "1" -r input_dir -q; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -s; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "1" -r input_dir -s; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -v "a" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -v "a" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -i "Si" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -i "Si" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -w "Si" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -w "Si" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -x "Don't" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -x "Don't" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -F "randomtext*" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -F "randomtext*" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -E "randomtext*" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -E "randomtext*" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "ye " input; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "ye " input; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "cold" input; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "cold" input; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN "not exist" input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN "not exist" input; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN ^D input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN ^D input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN .$ input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN .$ input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN \^ input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN \^ input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN \^$ input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN \^$ input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN ^[AEIOU] input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN ^[AEIOU] input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN ^[^AEIOU] input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN ^[^AEIOU] input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -E "free[^[:space:]]+" input2; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -E "free[^[:space:]]+" input2; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true

  { timeout $TIMEOUT $REDUCED_BIN -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' input; } >&$LOG || true
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  { timeout $TIMEOUT $ORIGIN_BIN -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' input; } >&log2
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q $LOG log2 >&/dev/null || true
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

  { timeout $TIMEOUT $REDUCED_BIN "a" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "a" -v -H -r input_dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -h -r input_dir; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -n "si" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -l; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -L; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "randomtext" -r input_dir -c; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -o [r][a][n][d]* input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -q; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "1" -r input_dir -s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -v "a" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -i "Si" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -w "Si" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -x "Don't" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -F "randomtext*" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -E "randomtext*" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "ye " input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "cold" input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN "not exist" input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN ^D input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN .$ input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN \^ input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN \^$ input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN ^[AEIOU] input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN ^[^AEIOU] input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -E "free[^[:space:]]+" input2; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  { timeout $TIMEOUT $REDUCED_BIN -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$MESSAGE" $LOG || true

  return 0
}

function infinite() {
  r=$1
  /bin/grep "Sanitizer" $LOG >&/dev/null && return 0
  if [[ $r -eq 124 ]]; then # timeout
    return 0
  else
    return 1
  fi
}

function outputcheckerror() {
  r="$1"
  if grep -q -E "$r" $LOG; then
    return 1
  fi
  return 0
}

OPT=("-G" "--basic-regexp" "-P" "--perl-regexp" "-e" "-z" "--null-data"
  "-V" "--version" "--help" "-b" "--byte-offset" "--line-buffered"
  "-a" "--text" "-I" "-R" "--dereference-recursive"
  "-T" "--initial-tab" "-Z" "--null" "-U"
  "-binary" "-u" "--unix-byte-offsets")
function undesired() {
  { timeout $TIMEOUT $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "OPTION" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN notexist; } >&$LOG # infite loop
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  infinite $r && true
  { $timeout $REDUCED_BIN notexist1 notexit2 notexist3; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  err=$?
  outputcheckerror "No such file or directory" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN "weird"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  infinite $r && true
  # cheap
  for opt in ${OPT[@]}; do
    { timeout 0.2 $REDUCED_BIN a $opt input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    crash $? && true
  done
  # expensive
  { timeout 0.5 $REDUCED_BIN a -f input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true

  { timeout $TIMEOUT $REDUCED_BIN a -A input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "input: invalid context length argument" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN a -B input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "input: invalid context length argument" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN a -C input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "input: invalid context length argument" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN a -m input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "invalid max count" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN a -d input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "invalid argument" && true
  crash $err && true
  { timeout $TIMEOUT $REDUCED_BIN a -D input; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  outputcheckerror "unknown devices method" && true
  crash $err && true

  export srcdir=$BENCHMARK_HOME/tests
  export abs_top_srcdir=$BENCHMARK_HOME
  export PATH_BK=$PATH
  export PATH="$(pwd):$PATH"
  for t in $(find tests/ -maxdepth 1 -perm -100 -type f); do
    { timeout 1 $t; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
    crash $? && true
  done
  export PATH=$PATH_BK
  return 0
}

main
