# Example of creating a "golden image" for virtualized workloads
Based off of the [IBM Cloud Plugin for Packer](https://github.com/IBM/packer-plugin-ibmcloud)
This repo supports running Packer locally to provision a Catalog image from IBM Cloud into your own VPC. The outcome will be a Custom Image in your account that can be provisioned.

## Install

### Clone repo
``` shell
git clone https://github.com/acmthinks/golden-image
```

### Install Packer
``` shell
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

### Install Ansible (>2.10)
https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems

### Set environment variables
These can also be stored in `.env` and sourced
``` shell
export ANSIBLE_INVENTORY_FILE="provisioner/hosts"
export ANSIBLE_HOST_KEY_CHECKING=False
export PACKER_LOG=1
export PACKER_LOG_PATH="packerlog/packerlog.txt"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

### Run Packer pipeline (locally)
Initialize Packer, validate, build.
``` shell
cd /golden-image
packer init -upgrade builders/build.vpc.centos.pkr.hcl
packer validate -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
packer build -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
```
