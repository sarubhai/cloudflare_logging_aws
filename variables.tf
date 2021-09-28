# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the infrastructure resources to onboard Cloudflare zone logs
# https://www.terraform.io/docs/configuration/variables.html

# AWS Provider
variable "credentials_file" {
  description = "Path to the AWS access credentials file."
}

variable "profile" {
  description = "AWS Profile name in the AWS access credentials file."
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}


# Tags
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
  default     = "Cloudflare"
}

variable "owner" {
  description = "This owner name tag will be included in the owner of the resources."
  default     = "Saurav"
}


# VPC & Subnets
variable "vpc_cidr_block" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the public subnet."
  default = {
    us-west-2a = "10.0.0.0/24"
  }
}

variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the private subnet."
  default = {
    us-west-2a = "10.0.1.0/24"
    us-west-2b = "10.0.2.0/24"
    us-west-2c = "10.0.3.0/24"
  }
}


# SQS
#    1. event_payload_queue
#    2. failed_download_to_s3_queue
#    3. failed_upload_to_elastic_queue

variable "queues" {
  description = "The list of queues to be created."
  default = {
    event_payload_queue            = "event_payload_queue",
    failed_download_to_s3_queue    = "failed_download_to_s3_queue"
    failed_upload_to_elastic_queue = "failed_upload_to_elastic_queue"
  }
}

variable "sqs_message_timeout" {
  description = "The length of time during which a message will be unavailable after a message is delivered from the queue."
  default     = 130
}


# Elasticsearch
variable "domain_suffix" {
  description = "The two elasticsearch domains suffixes to be created."
  default = {
    env1 = "prod",
    env2 = "uat"
  }
}

variable "elasticsearch_version" {
  description = "The elasticsearch version."
  default     = "7.9"
}

variable "datanode_instance_type" {
  description = "The Data Node Instance Type."
  default     = "t3.medium.elasticsearch"
}

variable "datanodes_count" {
  description = "The Number of Data Nodes."
  default     = 3
}

variable "ebs_volume_size_datanodes" {
  description = "The EBS Volume Size of Data Nodes in GiB."
  default     = 10
}

variable "masternode_instance_type" {
  description = "The Master Node Instance Type."
  default     = "t3.medium.elasticsearch"
}

variable "masternodes_count" {
  description = "The Number of Master Nodes."
  default     = 3
}

variable "master_user_name" {
  description = "The Master Username of Elasticsearch."
  default     = "elastic"
}

variable "master_user_password" {
  description = "The Master Password Elasticsearch."
  default     = "S3cret!234"
}


# Lambda Layers
variable "lambda_layer_runtimes" {
  description = "Lambda layer Runtime."
  default     = ["python3.7"]
}

variable "lambda_layer_license" {
  description = "Lambda layer License."
  default     = "Apache-2.0"
}

variable "requests_lambda_layer_s3key" {
  description = "The requests lambda layer s3 filename/key."
  default     = "lambda_layers/requests/python.zip"
}

variable "elasticsearch_lambda_layer_s3key" {
  description = "The elasticsearch lambda layer s3 filename/key."
  default     = "lambda_layers/elasticsearch/python.zip"
}

# Lambda Functions
variable "lambda_runtime" {
  description = "Lambda function Runtime."
  default     = "python3.7"
}

variable "lambda_memory" {
  description = "Lambda function memeory in MB."
  default     = 128
}

variable "lambda_timeout" {
  description = "The time out duration in seconds for Lambda function execution."
  default     = 120
}

variable "cloudflare_url" {
  description = "Cloudflare API endpoint for zones log."
  default     = "https://api.cloudflare.com/client/v4/zones/"
}



# S3 Log Buckets
variable "s3_log_expiration" {
  description = "The retention duration in days for objects in S3 buckets."
  default     = 90
}

# EventBridge Schedulers & S3 Log Buckets for each Zone/Domain
variable "zones_buckets" {
  description = "The list of rules for each zones to trigger cloudflare logs download"
  default = {
    zone1 = { s3_bucket = "cloudflare-saurav-logs-zone1", env : "prod", rate : 360 },
    zone2 = { s3_bucket = "cloudflare-saurav-logs-zone2", env : "prod", rate : 360 },
    zone3 = { s3_bucket = "cloudflare-saurav-logs-zone3", env : "uat", rate : 360 }
  }
}


# OPTIONAL TO CONNECT TO VPC USING VPN
# OpenVPN Access Server
variable "openvpn_server_instance_type" {
  description = "The OpenVPN Access Server Instance Type."
  default     = "t2.micro"
}

variable "vpn_admin_user" {
  description = "The OpenVPN Admin User."
  default     = "openvpn"
}

variable "vpn_admin_password" {
  description = "The OpenVPN Admin Password."
}
