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


### Run Packer pipeline (locally)
``` shell
cd /golden-image
packer init -upgrade builders/build.vpc.centos.pkr.hcl
packer validate -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
packer build -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
```
