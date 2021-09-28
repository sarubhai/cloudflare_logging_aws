# Name: domains.tf
# Owner: Saurav Mitra
# Description: This terraform config will create 2 Elasticsearch Domain resource for Production & UAT

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Need only once in AWS Account during 1st Elastic domain creation
# resource "aws_iam_service_linked_role" "es_role" {
#   aws_service_name = "es.amazonaws.com"
# }

# Create Elasticsearch Cluster
resource "aws_elasticsearch_domain" "elastic_domain" {
  for_each = var.domain_suffix

  domain_name           = lower("${var.prefix}-${var.owner}-${each.value}")
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    zone_awareness_enabled   = true
    instance_type            = var.datanode_instance_type
    instance_count           = var.datanodes_count
    dedicated_master_enabled = true
    dedicated_master_type    = var.masternode_instance_type
    dedicated_master_count   = var.masternodes_count

    zone_awareness_config {
      availability_zone_count = length(var.private_subnet_id)
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size_datanodes
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  vpc_options {
    subnet_ids         = var.private_subnet_id
    security_group_ids = [var.elastic_sg_id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${lower("${var.prefix}-${var.owner}-${each.value}")}/*"
        }
    ]
}
CONFIG

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  tags = {
    Name  = "${var.prefix}-elastic-${each.value}"
    Owner = var.owner
    Type  = each.value
  }

  # The ServiceRole is required before elasticsearch_domain resource can be created  
  #   depends_on = [aws_iam_service_linked_role.es_role]
}
