import json, boto3, logging, os
import requests as r

# Define log level: DEBUG, INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Set of required variables
required_variables = ["API_URL", "REGION", "STREAM_NAME"]

# Validation of required variables
if not all(elem in os.environ for elem in required_variables):
    raise Exception("One or more variables may not be set. Required variables: {variables}.".format(variables=required_variables))

# Instantiates Kinesis Stream client
client = boto3.client("kinesis", os.environ["REGION"])

def lambda_handler(event, context):
    """
    A handling function to call the Punk API 

    Keyword arguments:
        event -- A JSON-formatted document that contains data for a Lambda function to process
        context -- This object provides methods and properties that provide information about the invocation, function, and runtime environment.
    Returns:
        The requested API status code and body information
    """
    # EOL char append function
    encode_data = lambda x: "{data}{eol}".format(data=json.dumps(x), eol=chr(10)).encode("UTF-8")
    
    # Punk API call
    try:
        logger.debug("Requesting api: {api}".format(api=os.environ["API_URL"]))
        request = r.get(os.environ["API_URL"])
    except Exception as e:
        logger.error("An error occured while requesting api: {api}".format(api=os.environ["API_URL"]))
        raise e
    
    # Send records to kinesis stream
    logger.debug("Sending data to stream: {stream}".format(stream=os.environ["STREAM_NAME"]))
    for data in request.json():
        client.put_record(
                StreamName=os.environ["STREAM_NAME"],
                Data=encode_data(data),
                PartitionKey="key"
            )

    return {
        'statusCode': request.status_code,
        'body': data
    }
