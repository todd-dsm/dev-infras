#!/usr/bin/env bash
# shellcheck disable=SC2317,SC2154
#  PURPOSE: Removes KubeDB and related configs.
# -----------------------------------------------------------------------------
#  PREREQS: a)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1) Starting with minikube -> EKS
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2023/10/05
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
#: "${1?  Wheres the first agument, bro!}"

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
### Deleting the database
###---
kubectl -n "$kubeDbNs" delete -f "$pgSqlManifest"


###---
### Remove pgAdmin
###---
kubectl delete -f "$pgAdminManifest"


###---
### Wait for pods to complete before proceeding
###---
pMsg "Uninstalling KubeDB via Helm..."
helm delete kubedb --namespace kubedb


###---
### Print available CRDs
###---
kubectl delete namespace kubedb


###---
### Give it a moment to settle
###---
sleep 5s


###---
### fin~
###---
exit 0
