#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Create a private 'staging' subdomain for use with ExternalDNS.
#           REF: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#set-up-a-hosted-zone
# -----------------------------------------------------------------------------
#  PREREQS: a)
#           b)
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2021/10/00
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
#: "${1?  Wheres my first agument, bro!}"

# Data


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Create a 'staging' DNS zone
###---
aws route53 create-hosted-zone --name "${TF_VAR_envBuild}.${dns_zone}" \
    --hosted-zone-config "Comment=${TF_VAR_envBuild}-env,PrivateZone=true" \
    --caller-reference "external-dns-prep-$(date +%s)"


###---
### Get value for my-hostedzone-identifier
###---
hostedZoneID="$(aws route53 list-hosted-zones-by-name --output json \
    --dns-name "${TF_VAR_envBuild}.${dns_zone}" | jq -r '.HostedZones[0].Id')"


###---
### Make a note of the nameservers that were assigned to your new zone
###---
aws route53 list-resource-record-sets --output json \
    --hosted-zone-id "$hostedZoneID" \
    --query "ResourceRecordSets[?Type == 'NS']" | \
    jq -r '.[0].ResourceRecords[].Value'


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
