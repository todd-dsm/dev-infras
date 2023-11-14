#!/usr/bin/env make
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
TF_VAR_myProject	?= $(shell $(TF_VAR_myProject))
TF_VAR_envBuild 	?= $(shell $(TF_VAR_envBuild))
TF_VAR_filePlan 	?= $(shell $(TF_VAR_filePlan))

# Start Terraforming
all:	init plan apply creds 

init:	## Initialze the build
	terraform init -get=true -backend=true -reconfigure

plan:	## Initialze and Plan the build with output log
	terraform fmt -recursive=true
	terraform plan -no-color -out=$(filePlan) \
		2>&1 | tee /tmp/tf-$(TF_VAR_myProject)-plan.out

apply:	## Build Terraform project with output log
	terraform apply --auto-approve -no-color -parallelism=1 \
		-input=false $(filePlan) \
		2>&1 | tee /tmp/tf-$(TF_VAR_myProject)-apply.out

creds:	## Retrieve the public_ip address from the Instance
	@addons/eks/get-creds.sh

ekscfg: ## Additional Cluster Configurations
	#@addons/eks/add-cluster-configs.sh

divr:   ## ---------------------- 'make all' ends here ------------------------ 

data:   ## Install KubeDB to support locally managed DATA
	@addons/kubedb/kubedb-inst.sh
	@addons/kubedb/demo-config.sh

rmdb:   ## Install KubeDB to support locally managed DATA
	@addons/kubedb/kubedb-remove.sh

addr:	## Retrieve the public_ip address from the Instance
	terraform state show module.compute.aws_instance.test_instance | grep 'public_ip' | grep -v associate_public_ip_address

state:	## View the Terraform State File in VS-Code
	@scripts/view-tf-state.sh

clean:	## Clean WARNING Message
	@echo ""
	@echo "Destroy $(TF_VAR_myProject)?"
	@echo ""
	@echo "    ***** STOP, THINK ABOUT THIS *****"
	@echo "You're about to DESTROY ALL that we have built"
	@echo ""
	@echo "IF YOU'RE CERTAIN, THEN 'make clean-all'"
	@echo ""
	@exit

clean-all:	## Destroy Terraformed resources and all generated files with output log
	terraform apply -destroy -auto-approve -no-color 2>&1 | \
	 	tee /tmp/tf-$(TF_VAR_myProject)-destroy.out
	rm -f "$(filePlan)"
	rm -rf .terraform/ .terraform.lock.hcl

#-----------------------------------------------------------------------------#
#------------------------   MANAGERIAL OVERHEAD   ----------------------------#
#-----------------------------------------------------------------------------#
print-%  : ## Print any variable from the Makefile (e.g. make print-VARIABLE);
	@echo $* = $($*)

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

