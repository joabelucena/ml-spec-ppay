import json, boto3
import requests as r

def lambda_handler(event, context):
    request = r.get("https://api.punkapi.com/v2/beers/random")
    data = request.json()

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!'),
        'content': request.json()
    }
