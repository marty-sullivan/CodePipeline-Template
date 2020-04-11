import json
import logging
from datetime import datetime
from decimal import Decimal
from sys import stdout

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
sh = logging.StreamHandler(stdout)
formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
sh.setFormatter(formatter)
logger.addHandler(sh)
logging.getLogger('boto').setLevel(logging.WARN)
logging.getLogger('boto3').setLevel(logging.WARN)
logging.getLogger('botocore').setLevel(logging.WARN)
logging.getLogger('s3transfer').setLevel(logging.WARN)
logging.getLogger('urllib3').setLevel(logging.WARN)

def get_logger():
    return logger

def json_handler(o):
    if isinstance(o, datetime):
        return o.isoformat()
    elif isinstance(o, Decimal):
        return float(o)
    else:
        logger.warning('Unknown Type in json_handler: ' + str(o))
        return str(o)
    
def nearest(items, pivot):
  return min(items, key=lambda x: abs(x - pivot))
