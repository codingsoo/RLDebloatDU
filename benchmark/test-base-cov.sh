#!/bin/bash

function crash() {
  retval=$1
  log=$2
  # crash detected by shell
  if [[ $retval -eq 124 ]]; then # timeout
    return 0
  elif [[ $retval -gt 128 ]]; then
    return 0
  fi
  # crash detected by sanitizer
  echo $log | grep "Sanitizer" >&/dev/null && return 0
  return 1
}

function compile() {
  case $COV in
  1) CFLAGS="-w -fprofile-instr-generate -fcoverage-mapping $BENCHMARK_CFLAGS" ;;
  *) CFLAGS="-w -fprofile-instr-generate -fcoverage-mapping $1 $BENCHMARK_CFLAGS" ;;
  esac
  $CC $SRC $CFLAGS -o $REDUCED_BIN >&/dev/null || exit 1
  return 0
}

sanitizers=("-fsanitize=cfi -flto -fvisibility=hidden" "-fsanitize=address"
  "-fsanitize=memory -fsanitize-memory-use-after-dtor"
  "-fno-sanitize-recover=undefined,nullability"
  "-fsanitize=leak")

environments=("memory" "file")
environment_libs=("-L$BENCHMARK_HOME/lib -lmemwrap"
  "-L$BENCHMARK_HOME/lib -lfilewrap")

function main() {
  for ((i = 0; i < ${#sanitizers[@]}; i++)); do
    clean
    compile "${sanitizers[$i]}"
    desired "${sanitizers[$i]}"
#    undesired
    clean
  done
#  for ((i = 0; i < ${#environments[@]}; i++)); do
#    clean
#    compile "${environment_libs[$i]}"
#    desired_disaster "${environments[$i]}"
#    clean
#  done
}
