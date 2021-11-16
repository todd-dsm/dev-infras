#!/usr/bin/env bash

myState='/tmp/stage'


# Copy the remote file over to the local workstation
aws s3 cp s3://tf-state-taos-terraform-demo-west/env/stage "$myState"

# open the file
code "$myState"
