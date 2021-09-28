import boto3
import os
import logging
import json
import datetime
import requests
from elasticsearch import Elasticsearch, RequestsHttpConnection, helpers

# S3 config bucket
s3_config_bucket = os.environ['S3_CONFIG_BUCKET']
s3_config_file = os.environ['S3_CONFIG_FILE']

# Elasticsearch Settings
elastic_hostname_prod = os.environ['ELASTIC_HOSTNAME_PROD']
elastic_hostname_uat = os.environ['ELASTIC_HOSTNAME_UAT']
elastic_username = os.environ['ELASTIC_USERNAME']
elastic_password = os.environ['ELASTIC_PASSWORD']

# Elasticsearch Client
es = None

# Get the service resource.
s3Client = boto3.client('s3')

# Set the logger
log = logging.getLogger()
log.setLevel(logging.INFO)


# Connect to ES
def connectES(zone_env):
    elastic_hostname = elastic_hostname_prod if zone_env == "prod" else elastic_hostname_uat

    try:
        # Create Elasticsearch client
        es = Elasticsearch(
            [{ 'host': elastic_hostname, 'port': 443 }],
            http_auth=(elastic_username, elastic_password),
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection
        )
        return es
    except Exception as e:
        log.info("Failed connecting to Elasticsearch due to :{0}".format(str(e)))
        return None


# Main Handler
def lambda_handler(event, context):
    global es
    es = None

    # Zone Id
    zone_env = event["zone_env"]

    # Get Elasticsearch JSON configs
    s3_object = s3Client.get_object(Bucket=s3_config_bucket, Key="logs_index.json")
    content = s3_object['Body']
    logs_index_config = json.load(content)

    s3_object = s3Client.get_object(Bucket=s3_config_bucket, Key="cloudflare-index-template.json")
    content = s3_object['Body']
    cloudflare_index_template_config = json.load(content)

    s3_object = s3Client.get_object(Bucket=s3_config_bucket, Key="cloudflare-ingest-pipeline-daily.json")
    content = s3_object['Body']
    cloudflare_ingest_pipeline_config = json.load(content)

    # s3_object = s3Client.get_object(Bucket=s3_config_bucket, Key="dashboards.json")
    # content = s3_object['Body']
    # dashboard_config = json.load(content)
    
    # location = s3Client.get_bucket_location(Bucket=s3_config_bucket)['LocationConstraint']
    # fileurl = "https://s3-%s.amazonaws.com/%s/%s" % (location, s3_config_bucket, "dashboards.json")
    # fileurl = "s3://%s/%s" % (s3_config_bucket, "dashboards.json")
    
    # s3Client.download_file(s3_config_bucket, "dashboards.ndjson", "/tmp/dashboards.ndjson")
    # files = {'file': open('/tmp/dashboards.ndjson', 'rb')}
    
    try:
        if es is None:
            es = connectES(zone_env)
        if es is None:
            return {"status": "Error", "message": "Failed"}
        
        
        # Create Logs Index
        es.indices.create(index="logs", body=logs_index_config, ignore=400)
        # Verify Logs Index
        # mapping = es.indices.get_mapping(index="logs")
        # print(mapping)

        
        
        # Create Cloudflare Index Template
        es.indices.put_template(name="cloudflare",body=cloudflare_index_template_config)
        # Verify Cloudflare Index Template
        # template = es.indices.get_template(name="cloudflare")
        # print(template)
        
        
        
        # Create Cloudflare Ingest Pipeline
        es.ingest.put_pipeline(id="cloudflare-pipeline-daily",body=cloudflare_ingest_pipeline_config)
        # Verify Cloudflare Ingest Pipeline
        # pipeline = es.ingest.get_pipeline(id="cloudflare-pipeline-daily")
        # print(pipeline)
        
        
        
        # Import Cloudflare Dashboard
        # elastic_hostname = elastic_hostname_prod if zone_env == "prod" else elastic_hostname_uat
        # url = "https://" + elastic_hostname + "/_plugin/kibana/api/saved_objects/_import?overwrite=true"
        # response = requests.post(url, files=files, headers={'kbn-xsrf': 'true'})
        # response = requests.post(url, files=files, headers={'kbn-xsrf': 'true'}, auth=(elastic_username, elastic_password))
        # print(response.status_code)
        # print(response.content)
    


    except Exception as e:
        log.info("Failed due to :{0}".format(str(e)))
        raise e

    
    return {"status": "Success", "message": "Execution completed."}