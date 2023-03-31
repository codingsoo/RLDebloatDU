#!/bin/bash

export BENCHMARK_NAME=date-8.21
export BENCHMARK_DIR=$BENCHMARK_HOME/$BENCHMARK_NAME/merged
export SRC=$BENCHMARK_DIR/$BENCHMARK_NAME.c
export ORIGIN_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.origin
export REDUCED_BIN=$BENCHMARK_DIR/$BENCHMARK_NAME.reduced
export TIMEOUT="-k 0.1 0.1"
export LOG=$BENCHMARK_DIR/log.txt

source $BENCHMARK_HOME/test-base-cov.sh

function clean() {
  rm -rf $LOG temp temp1 temp2 f
  return 0
}

t0='08:17:48'
d0='1997-01-19'
d1="$d0 $t0 +0"
fmt="+%Y-%m-%d %T"
n_seconds=72057594037927935
function desired() {
  touch f
  $ORIGIN_BIN >&temp1
  { timeout 0.2 $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '02/29/1996 1 year' +%Y-%m-%d >&temp1
  { timeout 0.2 $REDUCED_BIN --date '02/29/1996 1 year' +%Y-%m-%d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1995-1-1' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1995-1-1' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1995-1-7' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1995-1-7' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1995-1-8' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1995-1-8' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-1' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-4' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-4' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-5' +%U >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-1' +%V >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-5' +%V >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-6' +%V >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-6' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-1' +%W >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-5' +%W >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1992-1-6' +%W >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1992-1-6' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --date '1998-1-1 3 years' +%Y >&temp1
  { timeout 0.2 $REDUCED_BIN --date '1998-1-1 3 years' +%Y; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d 'TZ="America/Los_Angeles" 09:00 next Fri' >&temp1
  { timeout 0.2 $REDUCED_BIN -d 'TZ="America/Los_Angeles" 09:00 next Fri'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 now" "+%Y-%m-%d %T" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 now" "+%Y-%m-%d %T"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 yesterday" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 yesterday" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 tomorrow" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 tomorrow" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 6 years ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 6 years ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 7 months ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 7 months ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 8 weeks ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 8 weeks ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --rfc-3339=ns -d'1970-01-01 00:00:00.2234567 UTC +961062237.987654321 sec' >&temp1
  { timeout 0.2 $REDUCED_BIN --rfc-3339=ns -d'1970-01-01 00:00:00.2234567 UTC +961062237.987654321 sec'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '2005-03-27 +1 day' '+%Y' >&temp1
  { timeout 0.2 $REDUCED_BIN -d '2005-03-27 +1 day' '+%Y'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d @-22 +%05s >&temp1
  { timeout 0.2 $REDUCED_BIN -d @-22 +%05s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d @-22 +%_5s >&temp1
  { timeout 0.2 $REDUCED_BIN -d @-22 +%_5s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  { $ORIGIN_BIN -d "$n_seconds" 2>&1 | cut -d ' ' -f 3; } >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$n_seconds"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q <(cat temp1) <(cut -d ' ' -f 3 $LOG) >&/dev/null || true

  $ORIGIN_BIN -d 1999-12-08 +%_3d >&temp1
  { timeout 0.2 $REDUCED_BIN -d 1999-12-08 +%_3d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d 1999-12-08 +%03d >&temp1
  { timeout 0.2 $REDUCED_BIN -d 1999-12-08 +%03d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "1999-12-08 7:30" "+%^c" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "1999-12-08 7:30" "+%^c"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --rfc-3339=ns -d "2038-01-19 03:14:07.999999999" >&temp1
  { timeout 0.2 $REDUCED_BIN --rfc-3339=ns -d "2038-01-19 03:14:07.999999999"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --rfc-3339=sec -d @31536000 >&temp1
  { timeout 0.2 $REDUCED_BIN --rfc-3339=sec -d @31536000; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --rfc-3339=date -d May-23-2003 >&temp1
  { timeout 0.2 $REDUCED_BIN --rfc-3339=date -d May-23-2003; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '1999-06-01' '+%3004Y' >&temp1
  { timeout 0.2 $REDUCED_BIN -d '1999-06-01' '+%3004Y'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --utc -d '1970-01-01 UTC +961062237 sec' "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -R -d "$d1" >&temp1
  { timeout 0.2 $REDUCED_BIN -R -d "$d1"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d 000909 "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d 000909 "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 4 seconds ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 4 seconds ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 4 seconds ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 4 seconds ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '20050101  1 day' +%F >&temp1
  { timeout 0.2 $REDUCED_BIN -d '20050101  1 day' +%F; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '20050101 +1 day' +%F >&temp1
  { timeout 0.2 $REDUCED_BIN -d '20050101 +1 day' +%F; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next second" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next second" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next minute" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next minute" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next hour" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next hour" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next day" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next day" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next week" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next week" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next month" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next month" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 next year" '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 next year" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u -d '08/01/97 6:00' '+%D,%H:%M' >&temp1
  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u -d '08/01/97 6:00 UTC +4 hours' '+%D,%H:%M' >&temp1
  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00 UTC +4 hours' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u --file=f '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -u --file=f '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -u --file=f '+%Y-%m-%d %T' >&temp1
  { timeout 0.2 $REDUCED_BIN -u --file=f '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '1970-01-01 00:00:01' +%s >&temp1
  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 00:00:01' +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '1970-01-01 00:00:01 UTC +2 hours' +%s >&temp1
  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 00:00:01 UTC +2 hours' +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d 2000-01-01 +%s >&temp1
  { timeout 0.2 $REDUCED_BIN -d 2000-01-01 +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d '1970-01-01 UTC 946684800 sec' +'%Y-%m-%d %T %z' >&temp1
  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 UTC 946684800 sec' +'%Y-%m-%d %T %z'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d0 $t0 this minute" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this minute" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d0 $t0 this hour" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this hour" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d0 $t0 this week" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this week" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d0 $t0 this month" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this month" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d0 $t0 this year" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this year" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 1 day ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 1 day ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 2 hours ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 2 hours ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -d "$d1 3 minutes ago" "$fmt" >&temp1
  { timeout 0.2 $REDUCED_BIN -d "$d1 3 minutes ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -f datefile >&temp1
  { timeout 0.2 $REDUCED_BIN -f datefile; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  $ORIGIN_BIN -r datefile >&temp1
  { timeout 0.2 $REDUCED_BIN -r datefile; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  diff -q temp1 $LOG >&/dev/null || true

  return 0
}

function desired_disaster_mem() {
  touch f

  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00 UTC +4 hours' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u --file=f '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  return 0
}

function desired_disaster_file() {
  touch f
  { timeout 0.2 $REDUCED_BIN; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '02/29/1996 1 year' +%Y-%m-%d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1995-1-1' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1995-1-7' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1995-1-8' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-4' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%U; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-6' +%V; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-1' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-5' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1992-1-6' +%W; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --date '1998-1-1 3 years' +%Y; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d 'TZ="America/Los_Angeles" 09:00 next Fri'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 now" "+%Y-%m-%d %T"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 yesterday" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 tomorrow" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 6 years ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 7 months ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 8 weeks ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --rfc-3339=ns -d'1970-01-01 00:00:00.2234567 UTC +961062237.987654321 sec'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '2005-03-27 +1 day' '+%Y'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d @-22 +%05s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d @-22 +%_5s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$n_seconds"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d 1999-12-08 +%_3d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d 1999-12-08 +%03d; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "1999-12-08 7:30" "+%^c"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --rfc-3339=ns -d "2038-01-19 03:14:07.999999999"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --rfc-3339=sec -d @31536000; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --rfc-3339=date -d May-23-2003; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '1999-06-01' '+%3004Y'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -R -d "$d1"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d 000909 "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '1996-11-10 0:00:00 +0' "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 4 seconds ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 4 seconds ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '20050101  1 day' +%F; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '20050101 +1 day' +%F; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next second" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next minute" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next hour" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next day" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next week" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next month" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 next year" '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u -d '08/01/97 6:00 UTC +4 hours' '+%D,%H:%M'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u --file=f '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -u --file=f '+%Y-%m-%d %T'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 00:00:01' +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 00:00:01 UTC +2 hours' +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d 2000-01-01 +%s; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d '1970-01-01 UTC 946684800 sec' +'%Y-%m-%d %T %z'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this minute" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this hour" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this week" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this month" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d0 $t0 this year" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 1 day ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 2 hours ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -d "$d1 3 minutes ago" "$fmt"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -f datefile; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  { timeout 0.2 $REDUCED_BIN -r datefile; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  grep -q -E "$1" $LOG || true

  return 0
}

function undesired() {
  { timeout 0.2 $REDUCED_BIN -I -d '2006-04-23 21 days ago'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN --iso -d May-23-2003; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN --iso=sec -d @31536000; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN --iso=ns -d "1969-12-31 13:00:00.000000.2-1100"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN --iso=ns -d "2038-01-19 03:14:07.999999999"; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%:::z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%:::z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%::z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%:::z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%:z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%8:z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN +%:8z; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  { timeout 0.2 $REDUCED_BIN --iso=ns -d'1970-01-01 00:00:00.2234567 UTC +961062237.987654321 sec'; } >&$LOG
llvm-profdata merge -sparse default.profdata default.profraw -o default.profdata
  crash $? && true
  return 0
}

function desired_disaster() {
  case $1 in
  memory)
    MESSAGE="memory exhausted"
    desired_disaster_mem "${messages[$i]}" || true
    ;;
  file)
    MESSAGE="write error"
    desired_disaster_file "${messages[$i]}" || true
    ;;
  *)
    return 1
    ;;
  esac
}

main
