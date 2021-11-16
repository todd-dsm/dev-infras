#!/usr/bin/env bash
set -x

# Put things back wheere they belong for the demo
mv mods/network/networking.tf newtfs/
mv mods/compute/instance.tf   newtfs/
mv mods/network/network-outputs.tf newtfs/
aws s3 rm s3://tf-state-taos-terraform-demo-west/env/prod
