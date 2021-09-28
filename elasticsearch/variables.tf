# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create 2 Elasticsearch Domain resource for Production & UAT

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}

variable "domain_suffix" {
  description = "The two elasticsearch domains suffixes to be created."
  type        = map(any)
}

variable "elasticsearch_version" {
  description = "The elasticsearch version."
}

variable "datanode_instance_type" {
  description = "The Data Node Instance Type."
}

variable "datanodes_count" {
  description = "The Number of Data Nodes."
}

variable "ebs_volume_size_datanodes" {
  description = "The EBS Volume Size of Data Nodes in GiB."
}

variable "masternode_instance_type" {
  description = "The Master Node Instance Type."
}

variable "masternodes_count" {
  description = "The Number of Master Nodes."
}

variable "master_user_name" {
  description = "The Master Username of Elasticsearch."
}

variable "master_user_password" {
  description = "The Master Password Elasticsearch."
}

variable "private_subnet_id" {
  description = "The private subnets ID."
}

variable "elastic_sg_id" {
  description = "Security Group for Elasticsearch Domains."
}