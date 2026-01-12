Create a "golden image" for virtualized workloads in IBM Cloud. Based off of the [IBM Cloud Plugin for Packer](https://github.com/IBM/packer-plugin-ibmcloud)
This repo supports running Packer locally to provision a stock IBM Cloud Catalog image into your own VPC. The outcome will be a Custom Image and a the image being stored in a COS bucket in your account that can be provisioned as a VSI in VPC or imported into OpenShift Virtualization.

This example pulls the IBM Cloud stock image for Centos, installs an EPEL package (yum), creates a "hello.txt" file, and saves the resultant image as a "custom image".
Here is how it works:
1. The stock catalog image is specified as `vsi_base_image_name` in the `build.vpc.centos/pkr.hcl` file
2. Packer provisions the `vsi_base_image_name` stock image as a virtual server instance (VSI) in a "golden-image" VPC. A Security Group is provisioned (with Public access to the Internet to download packages in step 5 below). A pair of SSH keys is provisioned to log on to the VSI.
3. Packer establishes an SSH session to the newly provisioned VSI.
4. Packer executes a shell command to create a file `hello.txt` and writes a simple message
5. Packer calls Ansible to perform the install of an OS package (in this case, EPEL)
6. Packer calls a post-provision hook to save the resultant image to an IBM Cloud COS bucket as a QCOW2 image. *This is an optional step, but useful for cases where "golden images" need to be more accessible or imported into OpenShift Virtualization*
6. Packer saves the resultant image as a "custom image" that can be provisioned later on as a VSI
7. Packer tears down the resultant VPC resources used to test the image(Security Group, SSH keys, and VSI). Note: the VPC and subnet will remain, but they will return to their empty beginning state

# Install

# Clone repo

``` shell
git clone https://github.com/acmthinks/golden-image
```

## Install Packer

For MacOS:
``` shell
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

## Install Ansible (>2.10)

https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems

## Set environment variables
These can also be stored in `.env` and sourced
``` shell
export ANSIBLE_INVENTORY_FILE="provisioner/hosts"
export ANSIBLE_HOST_KEY_CHECKING=False
export PACKER_LOG=1
export PACKER_LOG_PATH="packerlog/packerlog.txt"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```
## Set IBM Cloud variables

Create a and save a file `variables.pkrvars.hcl` with the values from the IBM Cloud account. If you provisioned a landing zone with https://github.com/acmthinks/golden-image-landing-zone grab the values of the output from `terraform apply`
``` shell
#Service ID API Key (COS credentials)
ibm_api_key = "<COS_CREDENTIAL_API_KEY>"

resource_group_id = "<IBMCLOUD_RESOURCE_GROUP_ID>"
region = "IBMCLOUD_REGION"
subnet_id = "VPC_SUBNET_ID"
cos_bucket = "BUCKET_NAME"
```

## Run
Initialize Packer, validate, build.
``` shell
cd /golden-image
packer init -upgrade builders/build.vpc.centos.pkr.hcl
packer validate -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
packer build -var-file=builders/variables.pkrvars.hcl builders/build.vpc.centos.pkr.hcl
```
