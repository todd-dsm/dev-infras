#!/usr/bin/env bash

myState='/tmp/stage'


# Copy the remote file over to the local workstation
aws s3 cp "s3://${TF_VAR_stateBucket}/env/${TF_VAR_envBuild}" "$myState"

# open the file
code "$myState"
