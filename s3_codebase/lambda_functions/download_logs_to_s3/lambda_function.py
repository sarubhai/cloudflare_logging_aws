import boto3
import botocore
import os
import logging
import json
import datetime
import requests
import botocore.vendored.requests.packages.urllib3 as urllib3
from botocore.exceptions import ClientError
from elasticsearch import Elasticsearch, RequestsHttpConnection, helpers

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
    
    for record in event['Records']:
        # Event Body
        body = json.loads(record["body"])
        # Zone Id
        zone_id = body["zone_id"]
        # Bucket Name
        s3_bucket = body["s3_bucket"]
        # Start
        start = body["start"]
        # End
        end = body["end"]
        # Filename
        filename = body["filename"]
        # Zone Env
        zone_env = body["zone_env"]
        # Log ID
        log_id = body["log_id"]
    
        
        try:
            if es is None:
                es = connectES(zone_env)
            if es is None:
                return {"status": "Error", "message": "Failed"}
            
            # Current Datetime
            currentDateTime = datetime.datetime.now()
            updated_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
            log.info(f"Current DatTime: {updated_at}")
            
            # URL
            url = os.environ['CLOUDFLARE_URL'] + zone_id + "/logs/received?start=" + start + "&end=" + end
            log.info(f"URL: {url}")
            
            log.info(f"Downloading file")
            
            status = 'downloading'
            # query = "UPDATE logs set status=%s, updated_at=%s WHERE id=%s;"
            # cur.execute(query, (status, updated_at, log_id,))
            doc = {
                "doc": {
                    "status": status,
                    "updated_at": updated_at
                }
            }
            json_response = es.update(index = "logs", id = log_id, body = doc)
            log.info(f"1 record {json_response['result']}")
            
            http = urllib3.PoolManager()
            response = http.request('GET', url, preload_content=False)
         
            fileobj = response
         
            path = f"s3://{s3_bucket}/{filename}"
            log.info(f"Uploading file to {path}")
         
            try:
                s3Client.upload_fileobj(fileobj, s3_bucket, filename)
                
                currentDateTime = datetime.datetime.now()
                updated_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
                status = 'downloaded'
                # query = "UPDATE logs set status=%s, updated_at=%s WHERE id=%s;"
                # cur.execute(query, (status, updated_at, log_id,))
                doc = {
                    "doc": {
                        "status": status,
                        "updated_at": updated_at
                    }
                }
                json_response = es.update(index = "logs", id = log_id, body = doc)
                log.info(f"1 record {json_response['result']}")
            
            except ClientError as e:
                log.info(f"Error Downloading file from {url}")
                return False
        except Exception as e:
            try:
                con.close()
            except Exception as e:
                con = None
            log.info("Failed due to :{0}".format(str(e)))
            raise e

    
    return {"status": "Success", "message": "Execution completed."}