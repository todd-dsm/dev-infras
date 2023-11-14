#!/usr/bin/env bash
# shellcheck disable=SC2317,SC2154
#  PURPOSE: Install KubeDB on a Kubernetes cluster.
# -----------------------------------------------------------------------------
#  PREREQS: a) configure the AppsCode Helm repo
#           b) Request the per-cluster license file.
#               https://license-issuer.appscode.com
#               Save to some place outside of the project repo
#           c) Iron Bank: there are further instructions for private registries
#               these are all config opts:
#               https://github.com/kubedb/installer/tree/v2023.08.18/charts/kubedb#configuration
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
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
#: "${1?  Wheres the first agument, bro!}"

# Data
licDir="$HOME/Downloads/kubedb"
licType='kubedb-enterprise-license'
myLicense="${licDir}/${licType}-${licKey}.txt"
#stat "$myLicense"


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
### Install KubeDB
###   NOTE: the community edition is not maintained very well; it's over a year
###         old and errors when following the instructions.
###---
helm install kubedb appscode/kubedb \
    --version "$versKubeDB" \
    --namespace kubedb --create-namespace \
    --set kubedb-provisioner.enabled=true \
    --set kubedb-ops-manager.enabled=true \
    --set kubedb-autoscaler.enabled=true \
    --set kubedb-dashboard.enabled=true \
    --set kubedb-schema-manager.enabled=true \
    --set-file global.license="$myLicense"


###---
### Wait for pods to complete before proceeding
###   * Usually the 'kubedb-ops-manager'; wait it out
###---
pMsg "Waiting for KubeDB to finish installation..."
kubectl -n kubedb wait --for=condition=Ready=true --timeout='60s' \
    pod -l "app.kubernetes.io/instance=kubedb"


###---
### Print available CRDs
###---
pMsg "These CRDs are now available on the system..."
kubectl get crd -l app.kubernetes.io/name=kubedb


###---
### Trail the logs for errors
###---
#kubectl -n kubedb logs -l app.kubernetes.io/instance=kubedb


###---
### fin~
###---
exit 0
