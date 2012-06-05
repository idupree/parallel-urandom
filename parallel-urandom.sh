#!/bin/sh
#Usage: parallel_urandom N
# runs N parallel cats from /dev/urandom and sends all the data to stdout.
#
# It seems there's an overhead to using the FIFO; `parallel_urandom 1`
# is about 2/3 the data rate of `dd if=/dev/urandom of=/dev/null`.
# Also it seems not to speed up linearly; I have 4 cores and the best
# seems to be `parallel_urandom 3` at about twice the speed of
# `dd if=/dev/urandom of=/dev/null`.

set -eu

num_parallel="$1"

# urandom children will be killed after
# we start reading the fifo and then stop,
# because of fifo semantics.
trap '{ { set +e; dd count=0 if="$dir/fifo"; rm "$dir/fifo"; rmdir "$dir"; } >/dev/null 2>/dev/null; }' EXIT

dir="$(mktemp -d --tmpdir par_urandom.XXXXXXXXXXXX)"
mkfifo -m 600 "$dir/fifo"
for n in `seq 1 "$num_parallel"`
do
  cat /dev/urandom >"$dir/fifo" &
done
cat "$dir/fifo"

