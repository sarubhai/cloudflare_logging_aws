import boto3
import os
import logging
import json
import datetime
import requests
import gzip
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
    
    # print(event)
    
    for record in event['Records']:
        # Event Body
        body = json.loads(record["body"])
        # Bucket Name
        s3_bucket = body['Records'][0]['s3']['bucket']['name']
        log.info(f"Bucket Name: {s3_bucket}")
        # Filename of object
        filename = body['Records'][0]['s3']['object']['key']
        log.info(f"Filename: {filename}")

        # Get the Bucket's Environment from config file
        s3_object = s3Client.get_object(Bucket=s3_config_bucket, Key=s3_config_file)
        content = s3_object['Body']
        data = json.load(content)
        zone_env = data[s3_bucket]

        try:
            if es is None:
                es = connectES(zone_env)
            if es is None:
                return {"status": "Error", "message": "Failed"}
            
            # Current Datetime
            currentDateTime = datetime.datetime.now()
            updated_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
            log.info(f"Current DatTime: {updated_at}")
            
            # Log ID
            # query = "SELECT id from logs where s3_bucket=%s and filename=%s"
            # cur.execute(query, (s3_bucket, filename,))
            dsl_query = {
                "query": {
                    "bool": {
                        "filter": [
                            { "term": { "s3_bucket": s3_bucket } },
                            { "term": { "filename": filename } }
                        ]
                    }
                },
                "_source": False
            }
            json_response = es.search(index = "logs", body = dsl_query)
            log_id = json_response['hits']['hits'][0]['_id']
            log.info(f"Log Id: {log_id}")
            
            path = f"s3://{s3_bucket}/{filename}"
            log.info(f"Uploading file {path} to Elastic")
            
            status = 'uploading'
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
            

            s3_object = s3Client.get_object(Bucket=s3_bucket, Key=filename)
            # print(s3_object)
            content = s3_object['Body']
            gzipfile = gzip.GzipFile(fileobj=content)
            
            # define an empty list for the Elasticsearch docs
            doc_list = []
            count = 0
            batch = 0
            agg = 0
            for line in gzipfile:
                json_object = json.loads(line)
                # add a new field to the Elasticsearch doc
                # json_object['pipeline'] = 'cloudflare-pipeline-daily'
                
                if count%1000 == 0:
                    response = helpers.bulk(es, doc_list, index='cloudflare', pipeline='cloudflare-pipeline-daily', stats_only=True)
                    batch = batch + 1
                    log.info(f"Batch {batch}: Flushing {response} logs to elasticsearch")
                    agg = agg + int(response[0])
                    doc_list = []
                
                # append the dict object to the list []
                doc_list += [json_object]
                
                count = count + 1
                
            if len(doc_list) > 0:
                response = helpers.bulk(es, doc_list, index='cloudflare', pipeline='cloudflare-pipeline-daily', stats_only=True)
                batch = batch + 1
                log.info(f"Batch {batch}: Flushing {response} logs to elasticsearch")
                agg = agg + int(response[0])
                
            log.info(f"Total rows in S3 file: {count}")
            log.info(f"Total rows indexed in elasticsearch: {agg}")
            log.info(f"Total Elasticsearch batches processed: {batch}")
            
            currentDateTime = datetime.datetime.now()
            updated_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
            status = 'uploaded'
            # query = "UPDATE logs set status=%s, s3_log_lines=%s, elastic_log_lines=%s, updated_at=%s WHERE id=%s;"
            # cur.execute(query, (status, count, agg, updated_at, log_id,))
            doc = {
                "doc": {
                    "status": status,
                    "s3_log_lines": count,
                    "elastic_log_lines": agg,
                    "updated_at": updated_at
                }
            }
            json_response = es.update(index = "logs", id = log_id, body = doc)
            log.info(f"1 record {json_response['result']}")

        except Exception as e:
            log.info("Failed due to :{0}".format(str(e)))
            raise e

    
    return {"status": "Success", "message": "Execution completed."}