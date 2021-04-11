import json, boto3, logging, csv
from base64 import b64encode, b64decode
from io import StringIO

# Define log level: DEBUG, INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    A handling function to transform Kinesis Firehose records

    Keyword arguments:
        event -- A JSON-formatted document that contains data for a Lambda function to process
        context -- This object provides methods and properties that provide information about the invocation, function, and runtime environment.
    Returns:
        A list of transformed records
    """
    # base64 decode and encode function
    decode = lambda x: b64decode(x).decode("UTF-8")
    encode = lambda x: b64encode(x.encode("UTF-8")).decode("UTF-8")

    # dict extract function
    extract_cols = lambda data, cols: {key: data[key] for key in cols}
    cols = ['id','name','abv','ibu','target_fg','target_og','ebc','srm','ph']
    
    try:
        # retrieves first record for appending header. This is required for Glue to correctly schema infering
        records = event["records"]
        firstRecordId = records[0]["recordId"]
        
        # Steps will not be logged because map is a lazy operation. In case any errors occurs a Exception will be raised 
        # containing more details.
        records = map(lambda x: x.update(data = json.loads(decode(x["data"]))) or x                             , records)
        records = map(lambda x: x.update(data = extract_cols(x["data"], cols)) or x                             , records)
        records = map(lambda x: x.update(data = dict_to_csv(x["data"], x["recordId"], firstRecordId)) or x      , records)
        records = map(lambda x: x.update(data = encode(x["data"])) or x                                         , records)
        records = map(lambda x: dict(data = x["data"], result = "Ok", recordId = x["recordId"]) or x            , records)
        
    except Exception as e:
        logger.error("An error occured while tranforming records. An Exception will be raised.")
        raise e

    return {
        "records": list(records)
    }

def dict_to_csv(data, recordId, firstRecordId):
    """
    Transforms a dict to a csv string

    Keyword arguments:
        data -- the dict
        recordId -- identification for the record. This will be compared to firstRecordId in order to append the header
        firstRecordId -- First record identification
    Returns:
        A CSV string of passing dict.
    """
    f = StringIO()
    w = csv.writer(f)
    if recordId == firstRecordId:
        w.writerow(data.keys())
    w.writerow(data.values())
    f.seek(0)
    return f.read()