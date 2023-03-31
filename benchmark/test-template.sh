#!/bin/bash

export BENCHMARK_NAME= # TODO
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT= # TODO
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base.sh

function clean() {
  # TODO
  return 0
}

function desired() {
  # TODO
}

function undesired() {
  # TODO
}

function desired_disaster() {
  # TODO
}

main
