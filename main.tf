# main.tf
# Owner: Saurav Mitra
# Description: This terraform config will create the infrastructure resources to onboard Cloudflare zone logs 
# to S3 Buckets & Elasticsearch Domains (Production & UAT) scheduled at a regular interval


# Configure Terraform 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure AWS Provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# $ export AWS_ACCESS_KEY_ID="AccessKey"
# $ export AWS_SECRET_ACCESS_KEY="SecretKey"

provider "aws" {
  shared_credentials_file = var.credentials_file
  profile                 = var.profile
  region                  = var.region
}


# VPC & Subnets
module "vpc" {
  source          = "./vpc"
  prefix          = var.prefix
  owner           = var.owner
  vpc_cidr_block  = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# IAM
module "iam" {
  source = "./iam"
  prefix = var.prefix
  owner  = var.owner
}

# Security Groups
module "sg" {
  source         = "./sg"
  prefix         = var.prefix
  owner          = var.owner
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
}


# SQS
module "sqs" {
  source              = "./sqs"
  prefix              = var.prefix
  owner               = var.owner
  queues              = var.queues
  sqs_message_timeout = var.sqs_message_timeout
}


# Elasticsearch
module "elasticsearch" {
  source                    = "./elasticsearch"
  prefix                    = var.prefix
  owner                     = var.owner
  domain_suffix             = var.domain_suffix
  elasticsearch_version     = var.elasticsearch_version
  datanode_instance_type    = var.datanode_instance_type
  datanodes_count           = var.datanodes_count
  ebs_volume_size_datanodes = var.ebs_volume_size_datanodes
  masternode_instance_type  = var.masternode_instance_type
  masternodes_count         = var.masternodes_count
  master_user_name          = var.master_user_name
  master_user_password      = var.master_user_password
  private_subnet_id         = module.vpc.private_subnet_id
  elastic_sg_id             = module.sg.elastic_sg_id
}



# S3 Config
module "s3_config" {
  source = "./s3_config"
  prefix = var.prefix
  owner  = var.owner
}

# S3 Bucket for Lambda Codes
module "s3_codebase" {
  source = "./s3_codebase"
  prefix = var.prefix
  owner  = var.owner
}

# Lambda Layers
module "lambda_layer" {
  source                           = "./lambda_layer"
  s3_code_bucket_name              = module.s3_codebase.s3_code_bucket_name
  requests_lambda_layer_s3key      = var.requests_lambda_layer_s3key
  elasticsearch_lambda_layer_s3key = var.elasticsearch_lambda_layer_s3key
  lambda_layer_runtimes            = var.lambda_layer_runtimes
  lambda_layer_license             = var.lambda_layer_license
  # The Lambda Layers are dependent on the uploaded library files as zip in S3 Codebase bucket
  depends_on = [module.s3_codebase]
}

# Lambda Functions
module "lambda_function" {
  source                             = "./lambda_function"
  prefix                             = var.prefix
  owner                              = var.owner
  lambda_runtime                     = var.lambda_runtime
  lambda_memory                      = var.lambda_memory
  lambda_timeout                     = var.lambda_timeout
  lambda_iam_role_arn                = module.iam.lambda_iam_role_arn
  private_subnet_id                  = module.vpc.private_subnet_id
  lambda_sg_id                       = module.sg.lambda_sg_id
  requests_lambda_layer_arn          = module.lambda_layer.requests_lambda_layer_arn
  elasticsearch_lambda_layer_arn     = module.lambda_layer.elasticsearch_lambda_layer_arn
  s3_code_bucket_name                = module.s3_codebase.s3_code_bucket_name
  prod_elastic_endpoint              = module.elasticsearch.prod_elastic_endpoint
  uat_elastic_endpoint               = module.elasticsearch.uat_elastic_endpoint
  event_payload_queue_url            = module.sqs.event_payload_queue_url
  master_user_name                   = var.master_user_name
  master_user_password               = var.master_user_password
  cloudflare_url                     = var.cloudflare_url
  event_payload_queue_arn            = module.sqs.event_payload_queue_arn
  failed_download_to_s3_queue_arn    = module.sqs.failed_download_to_s3_queue_arn
  failed_upload_to_elastic_queue_arn = module.sqs.failed_upload_to_elastic_queue_arn
  s3_config_bucket_name              = module.s3_config.s3_config_bucket_name
  s3_config_file                     = module.s3_config.s3_config_file
  # The Lambda Functions are dependent on the uploaded library files as zip in S3 Codebase bucket
  # as well as config files as json/ndjson in S3 Config bucket
  depends_on = [module.s3_codebase, module.s3_config]
}


# Initial Elasticsearch Objects Setup by Invoking Lambda function 
module "lambda_invocation" {
  source        = "./lambda_invocation"
  domain_suffix = var.domain_suffix
  # The Lambda Function invocation depends on Elasticsearch Domains & the Lambda Functions creation
  depends_on = [module.elasticsearch, module.lambda_function]
}




# S3 Log Download Buckets
module "s3" {
  source                     = "./s3"
  prefix                     = var.prefix
  owner                      = var.owner
  zones_buckets              = var.zones_buckets
  s3_log_expiration          = var.s3_log_expiration
  upload_logs_to_elastic_arn = module.lambda_function.upload_logs_to_elastic_arn
}

# EventBridge Schedulers
module "event_bridge" {
  source                                   = "./event_bridge"
  prefix                                   = var.prefix
  owner                                    = var.owner
  zones_buckets                            = var.zones_buckets
  generate_parameters_for_log_download_arn = module.lambda_function.generate_parameters_for_log_download_arn
  # The Event Schedulers are dependent on the json config file in S3 Config bucket 
  # as well as the target S3 Log Download Buckets
  depends_on = [module.s3_config, module.s3]
}


# OPTIONAL TO CONNECT TO VPC USING VPN
# OpenVPN Server
module "openvpn" {
  source                       = "./openvpn"
  prefix                       = var.prefix
  owner                        = var.owner
  vpc_id                       = module.vpc.vpc_id
  public_subnet_id             = module.vpc.public_subnet_id
  openvpn_server_instance_type = var.openvpn_server_instance_type
  vpn_admin_user               = var.vpn_admin_user
  vpn_admin_password           = var.vpn_admin_password
}