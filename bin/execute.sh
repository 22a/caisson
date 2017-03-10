#!/bin/bash

# rename args for readability, there's probably a better way to do this...
# TODO: find that better way
lang=$1
time_limit=$2
mem_limit=$3
payload_path=$4
proc_path=$5
docker_image=$6

# set up execution env TODO: apply sec patches
# spawn container from image
con_hash=$(sudo docker run -dt --network=none --user=nobody --cap-drop=all $docker_image /bin/sh)

# inject procedure script
sudo docker cp $proc_path $con_hash:/exec.sh
# inject payload
sudo docker cp $payload_path $con_hash:/payload

# capture output from payload execution, enforce timeout
# send SIGKILL to make docker play ball and exit
output=$(sudo timeout -s 9 $time_limit sudo docker exec $con_hash /bin/sh exec.sh)
# capture exit code from above timeout
timeout_exit_code=$?

# kill the container
sudo docker rm -f $con_hash &> /dev/null

# TODO: consider not storing output and echoing later
echo $output

# pass exit code back up to calling process
exit $timeout_exit_code
