#!/usr/bin/env bash
#  PURPOSE: Create a ConfigMap for SRE access to the cluster. By default, only
#           the cluster creator can access the new cluster. The ConfigMap is a
#           definition of 'who' should be able to access it; typically a group.
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
#  CREATED: 2020/12/05
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
: "${TF_VAR_cluster_apps?    Whats the cluster name, bro!}"
sreConfigMapTmpl='addons/eks/aws-auth-cm.tmpl'
sreConfigMapTarget='addons/eks/aws-auth-cm.target'
sreConfigMapDef='/tmp/aws-auth-cm.yaml'
# REF: https://eksctl.io/usage/iam-identity-mappings
#export workerRoleARN="$(eksctl get iamidentitymapping \
#    --cluster="$TF_VAR_cluster_apps" | awk 'NR > 1 {print $1}')"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '\n%s\n' "$theMessage"
}

function pHeadline() {
    theMessage="$1"
    printf '\n\n%s\n\n' """
    *********************************************
      $theMessage
    *********************************************
    """
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Create the Definition from the Template
###---
pMsg "Creating the ConfigMap for SRE cluster access"
envsubst < "$sreConfigMapTmpl" > "$sreConfigMapDef"


###---
### Validate; the Definition should always match the Target
### The Target shouldnt change much
###---
#pMsg "Validating there is no drift in the ConfigMap"
#pMsg "  Diff output regarding the eksctl-pipes-dev-nodegroup-* are okay."
#if ! diff "$sreConfigMapTarget" "$sreConfigMapDef"; then
#    pMsg "  The ConfigMap Definition does not match the Target."
#    exit 1
#fi


###---
### Record ConfigMap pre-conditions
###---
pHeadline "Recording ConfigMap PRE-conditions:"
kubectl -n kube-system describe configmap/aws-auth


###---
### Add SREs to the cluster
###---
kubectl apply -f "$sreConfigMapDef"


###---
### Record ConfigMap post-conditions
###---
pHeadline "Recording ConfigMap POST-conditions:"
kubectl -n kube-system describe configmap/aws-auth


###---
### REQ
###---


###---
### fin~
###---
exit 0
