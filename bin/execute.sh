# name of docker image, python base for now
# TODO: build better one with more langs
exe_image="python"

# rename args for readability, there's probably a better way to do this...
# TODO: find that better way
lang=$1
time_limit=$2
mem_limit=$3
payload_path=$4
proc_path=$5

# set up execution env TODO: apply sec patches
# spawn container from image
con_hash=$(docker run -dt --network=none --user=nobody --cap-drop=all $exe_image /bin/bash)
# inject procedure script
docker cp $proc_path $con_hash:/exec.sh
# inject payload
docker cp $payload_path $con_hash:/payload

# compile/execute the payload TODO: incorporate limits here
docker exec $con_hash /bin/bash exec.sh

# kill the container
docker rm -f $con_hash > /dev/null
