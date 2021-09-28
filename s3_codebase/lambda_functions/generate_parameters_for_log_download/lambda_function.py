import boto3
import os
import logging
import json
import datetime
import math
import requests
from elasticsearch import Elasticsearch, RequestsHttpConnection, helpers

# Elasticsearch Settings
elastic_hostname_prod = os.environ['ELASTIC_HOSTNAME_PROD']
elastic_hostname_uat = os.environ['ELASTIC_HOSTNAME_UAT']
elastic_username = os.environ['ELASTIC_USERNAME']
elastic_password = os.environ['ELASTIC_PASSWORD']

# SQS Settings
sqs_endpoint_url = os.environ['SQS_ENDPOINT_URL']
sqs_queue_url = os.environ['SQS_QUEUE_URL']

# Elasticsearch Client
es = None

# Get the service resource.
sqsClient = boto3.client('sqs', endpoint_url = sqs_endpoint_url)

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
    
    # Test elasticsearch connection
    # if not es.ping():
    #     raise ValueError("Cannot Connect to Elasticsearch cluster")
    # else:
    #     log.info(f"Connected to Elasticsearch cluster")


# Log & Invoke Lambda
def log_invoke_lambda(zone_id, s3_bucket, zone_env, rate, es, starting, ending, created_at):
    # Format Datetime
    start = starting.strftime("%Y-%m-%dT%H:%M") + ":00Z"
    start_time = starting.strftime("%Y-%m-%d %H:%M") + ":00"
    log.info(f"Start DatTime: {start}")
    
    end = ending.strftime("%Y-%m-%dT%H:%M") + ":00Z"
    end_time = ending.strftime("%Y-%m-%d %H:%M") + ":00"
    log.info(f"End DateTime: {end}")
    
    # Filename
    filename = starting.strftime("%Y%m%d___%H-%M") + "_" + ending.strftime("%H-%M") + ".gz"
    log.info(f"Filename: {filename}")

    # Log metadata
    status = 'invoking'
    # query = "INSERT INTO logs (zone_id, s3_bucket, start_time, end_time, rate, status, filename, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id;"
    # cur.execute(query, (zone_id, s3_bucket, start_time, end_time, rate, status, filename, created_at, created_at))
    doc = {
        "zone_id": zone_id,
        "s3_bucket": s3_bucket,
        "start_time": start_time,
        "end_time": end_time,
        "rate": rate,
        "status": status,
        "filename": filename,
        "created_at": created_at,
        "updated_at": created_at
    }
    json_response = es.index(index = "logs", body = doc)
    log_id = json_response['_id']
    log.info(f"Logs Row Id: {log_id}")
    
    # Parameters Set
    input_parameters = {
        "zone_id"   : zone_id,
        "s3_bucket" : s3_bucket,
        "start"     : start,
        "end"       : end,
        "filename"  : filename,
        "zone_env"  : zone_env,
        "log_id"    : log_id
    }
    
    # Send event payload to SQS
    response = sqsClient.send_message(
        QueueUrl    = sqs_queue_url,
        MessageBody = json.dumps(input_parameters)
    )
    log.info(f"Event Response: {response}")
    
    status = 'invoked'
    currentDateTime = datetime.datetime.now()
    updated_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
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


# Main Handler
def lambda_handler(event, context):
    global es
    es = None

    # Zone Id
    zone_id = event["zone_id"]
    # Bucket Name
    s3_bucket = event["s3_bucket"]
    # Zone Environment
    zone_env = event["env"]
    # Rate Interval
    rate = event["rate"]

    
    try:
        if es is None:
            es = connectES(zone_env)
        if es is None:
            return {"status": "Error", "message": "Failed"}
        
        # Current Datetime
        currentDateTime = datetime.datetime.now()
        created_at = currentDateTime.strftime("%Y-%m-%d %H:%M:%S")
        log.info(f"Current DatTime: {created_at}")
    
        # Get latest log pull end date
        # query = "SELECT max(end_time) from logs where zone_id=%s"
        dsl_query = {
            "aggs": {
                "zones": {
                    "filter": { "term": { "zone_id": zone_id } },
                    "aggs": {
                        "max_end_time": { "max": { "field": "end_time" } }
                    }
                }
            }
        }
        json_response = es.search(index = "logs", body = dsl_query)
        max_end_time = json_response['aggregations']['zones']['max_end_time']['value']

        # First-time execution
        if max_end_time is None:
            log.info(f"Max End Time: NULL")
            # Start Time = Rate+1 Minutes Ago from now
            starting = currentDateTime - datetime.timedelta(minutes=rate+1)
            # End Time = 1 Minutes Ago from now
            ending = currentDateTime - datetime.timedelta(minutes=1)
            log_invoke_lambda(zone_id, s3_bucket, zone_env, rate, es, starting, ending, created_at)
        
        # Subsequent executions
        else:
            max_end_time_string = json_response['aggregations']['zones']['max_end_time']['value_as_string']
            max_end_time = datetime.datetime.strptime(max_end_time_string, "%Y-%m-%d %H:%M:%S")
            log.info(f"Max End Time: {max_end_time}")
            # Time difference in minutes between 1 Minutes Ago from now & latest log pull end date 
            currentEnding = datetime.datetime.strptime((currentDateTime - datetime.timedelta(minutes=1)).strftime("%Y-%m-%d %H:%M") + ":00", "%Y-%m-%d %H:%M:%S")
            log.info(f"Current End Time: {currentEnding}")
            minutes_diff = math.trunc((datetime.datetime.strptime(currentEnding.strftime("%Y-%m-%d %H:%M") + ":00", "%Y-%m-%d %H:%M:%S") - max_end_time).total_seconds() / 60.0)
            log.info(f"Execution time difference: {minutes_diff}")
            
            # if difference > rate
            if minutes_diff > rate:
                # loop to set date/time and invoke
                starting = max_end_time
                for i in range(math.trunc(minutes_diff/rate)):
                    ending = min( datetime.datetime.strptime((starting + datetime.timedelta(minutes=rate)).strftime("%Y-%m-%d %H:%M") + ":00", "%Y-%m-%d %H:%M:%S"), currentEnding )
                    log.info(f"Range- {starting} to {ending}")
                    rate = math.trunc((ending - starting).total_seconds() / 60.0)
                    log_invoke_lambda(zone_id, s3_bucket, zone_env, rate, es, starting, ending, created_at)
                    starting = ending
                
                if starting != currentEnding:
                    # Process last range
                    log.info(f"Range- {starting} to {currentEnding}")
                    rate = math.trunc((currentEnding - starting).total_seconds() / 60.0)
                    log_invoke_lambda(zone_id, s3_bucket, zone_env, rate, es, starting, currentEnding, created_at)    
            else:
                # Start Time = Rate+1 Minutes Ago from now
                starting = max_end_time
                # End Time = 1 Minutes Ago from now
                ending = currentDateTime - datetime.timedelta(minutes=1)
                rate = math.trunc((ending - starting).total_seconds() / 60.0)
                log_invoke_lambda(zone_id, s3_bucket, zone_env, rate, es, starting, ending, created_at)
        
    except Exception as e:
        log.info("Failed due to :{0}".format(str(e)))
        raise e

    
    return {"status": "Success", "message": "Execution completed."}