#!/usr/bin/env bash
# shellcheck disable=SC2154
#set -x

# Put things back wheere they belong for the demo
mv mods/network/networking.tf newtfs/
mv mods/compute/instance.tf   newtfs/
mv mods/network/network-outputs.tf newtfs/
aws s3 rm s3://tf-state-taos-terraform-demo-west/env/prod

# Sometimes the log-group just wont delete
logExist="$(aws logs describe-log-groups \
    --log-group-name-prefix="vpc_network_flow_${TF_VAR_envBuild}_logs" --output text)"
if [[ "$logExist" != '' ]]; then
    echo "Deleting the lingering log group..."
    aws logs delete-log-group \
        --log-group-name="vpc_network_flow_${TF_VAR_envBuild}_logs"
fi
