#!/bin/sh
INSTANCE_COUNT=2

for i in `seq 1 $INSTANCE_COUNT`;
do
  echo "Launching game instance $i"
  elixir --name "$i@127.0.0.1" -S mix scenic.run &
  sleep 1
done
echo "Done. To stop an instance close its window."
