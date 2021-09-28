# Cloudflare Logging to AWS Infra:

Configure infrastructure in AWS using Terraform.
Cloudflare Logging for multiple Zones with Log Pull method. Log Analytics using Elasticsearch & Log archival to S3 buckets.
Reference- [https://developers.cloudflare.com/logs/logpull](https://developers.cloudflare.com/logs/logpull)

## AWS Resources

### VPC & Subnets

- 1 Virtual Private Cloud
- 3 Private Subnets
- 3 Public Subnets
- 1 Internet Gateway
- 1 NAT Gateway for outbound internet access
- 1 Elastic IP for NAT Gateway
- 2 Routing tables (for Public and Private subnet for routing the traffic)

### IAM

- 1 IAM Role for Lambda Functions

### Security Groups

- 1 Security Group for Lambda Functions
- 1 Security Group for Elasticsearch Domain

### SQS

- 1 Event Payload Queue
- 1 Failed Download To S3 Queue
- 1 Failed Upload To Elasticsearch Queue

### Elasticsearch

- 1 Elasticsearch Domain for UAT Zone Logs
- 1 Elasticsearch Domain for PROD Zone Logs

### S3 Config

- 1 S3 Bucket to upload Elasticsearch Object config files

### S3 Bucket for Lambda Codes

- 1 S3 Bucket to upload Lambda Functions Code

### Lambda Layers

- 2 Lambda Layers for Python Libraries (py_requests, py_elasticsearch)

### Lambda Functions

- Lambda Function to generate the parameters for log download
- Lambda Function to download logs to S3
- Lambda Function to upload logs to Elasticsearch
- Lambda Function to retry failed download logs to S3
- Lambda Function to retry failed upload logs to Elasticsearch
- Lambda Function to create initial Elasticsearch objects like Index, Pipelines & Kibana Dashboards

### Invoke Lambda function

- Lambda Function to create initial Elasticsearch objects like Index, Pipelines & Kibana Dashboards

### S3 Log Download Buckets

- S3 Log Download Buckets for multiple Zones

### EventBridge Schedulers

- EventBridge rules/schedules to download cloudflare logs for multiple zones

### OpenVPN Server

- OPTIONAL TO CONNECT TO VPC USING VPN
