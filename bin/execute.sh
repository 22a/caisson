#!/bin/bash

# rename args for readability, there's probably a better way to do this...
# TODO: find that better way
lang=$1
time_limit=$2
mem_limit=$3
payload_path=$4
proc_path=$5
docker_image=$6

hard_time_limit=$((time_limit+1))

# set up execution env TODO: apply sec patches
# spawn container from image
con_hash=$(sudo docker run -dt \
              --network=none \
              --user=nobody \
              --cap-drop=all \
              --cap-add=sys_nice \
              --ulimit core=0 \
              --ulimit fsize=10000 \
              --ulimit nofile=1024 \
              --ulimit cpu=$hard_time_limit \
              --memory=10m \
              --memory-swap=0 \
              --memory-swappiness=0 \
              --kernel-memory=4M \
              $docker_image /bin/sh 2> /dev/null)

# limit output
echo " 2>&1 | head -c 10000" >> $proc_path

# inject procedure script
sudo docker cp $proc_path $con_hash:/exec.sh
# inject payload
sudo docker cp $payload_path $con_hash:/payload

# enforce timeout on code execution
sudo timeout $time_limit sudo docker exec $con_hash /bin/sh exec.sh

# capture exit code from above timeout
timeout_exit_code=$?

# kill the container
sudo docker rm -f $con_hash &> /dev/null

# pass exit code back up to calling process
exit $timeout_exit_code
