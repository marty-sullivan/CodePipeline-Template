import logging
from boto3.session import Session
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
logging.getLogger('boto').setLevel(logging.WARN)
logging.getLogger('boto3').setLevel(logging.WARN)
logging.getLogger('botocore').setLevel(logging.WARN)
logging.getLogger('s3transfer').setLevel(logging.WARN)
logging.getLogger('urllib3').setLevel(logging.WARN)

aws = Session()

def lambda_handler(event, context):
  return event
