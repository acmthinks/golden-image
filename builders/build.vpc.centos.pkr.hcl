
packer {
  required_plugins {
    ibmcloud = {
      version = ">=v3.0.0"
      source  = "github.com/IBM/ibmcloud"
    }
  }
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "ibm_api_key" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "resource_group_id" {
  type    = string
  default = null
}

variable "ansible_inventory_file" {
  type    = string
  default = "${env("ANSIBLE_INVENTORY_FILE")}"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "ibmcloud-vpc" "centos" {
  api_key = "${var.ibm_api_key}"
  region  = "${var.region}"

  subnet_id         = "${var.subnet_id}"
  resource_group_id = "${var.resource_group_id}"
  security_group_id = ""

  vsi_base_image_name = "ibm-centos-stream-10-amd64-5"
  vsi_profile         = "bx2-2x8"
  vsi_interface       = "public"
  vsi_user_data_file  = ""
  image_name          = "packer-${local.timestamp}"

  communicator = "ssh"
  ssh_username = "root"
  ssh_port     = 22
  ssh_timeout  = "2m"

  timeout = "30m"
}

build {
  sources = [
    "source.ibmcloud-vpc.centos"
  ]

  ##############################################################################
  ## Provision golden image in IBM Cloud (setup/teardown), create custom Image
  ##############################################################################
  provisioner "shell" {
    execute_command = "{{.Vars}} bash '{{.Path}}'"
    inline = [
      "echo 'Hello from IBM Cloud Packer Plugin - VPC Infrastructure.'",
      "echo 'Hello from IBM Cloud Packer Plugin - VPC Infrastructure.' >> /hello.txt"
    ]
  }

  ##############################################################################
  ## Optional: Run any additional configurations with an Ansible playbook
  ##############################################################################
  provisioner "ansible" {
    playbook_file = "provisioner/centos-playbook.yml"
  }

  ##############################################################################
  ## Optional: Store golden image to COS (qcow2 format)
  ##############################################################################
  #post-processors {
  #  post-processor "ibmcloud-export-image" {
  #    image_export_job_name   = "image-export-job-${local.timestamp}"
  #    storage_bucket_name     = "bucket-name"
  #    format                  = "qcow2"
  #    export_timeout          = "12m"
  #  }
  #}
}
