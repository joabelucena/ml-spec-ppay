import json, boto3, logging
import requests as r

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
client = boto3.client("kinesis", "us-east-1")

def lambda_handler(event, context):
    encode_data = lambda x: "{data}{eol}".format(data=json.dumps(x), eol=chr(10)).encode("UTF-8")
    request = r.get("https://api.punkapi.com/v2/beers/random")
    
    for data in request.json():
        client.put_record(
                StreamName="punk_api_serving_stream",
                Data=encode_data(data),
                PartitionKey="key"
            )
    
    return {
        'statusCode': 200,
        'body': data
    }
