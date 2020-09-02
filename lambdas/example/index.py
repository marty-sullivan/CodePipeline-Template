from boto3.session import Session
from codebase import get_logger, json_handler
from codebase.responses import http_response, client_error, critical_error, server_error
from codebase.exceptions import ServerlessClientException, ServerlessException
from os import environ
import json
import logging

logger = get_logger()

def lambda_handler(event, context):
  logger.debug('Request ' + json.dumps(event, default=json_handler))
  
  try:
    return http_response(
      Body='Hello World!',
      StatusCode='200',
      ContentType='text/plain',
    )

  except ServerlessClientException as e:
    return client_error(e)
  
  except ServerlessException as e:
    return server_error(e)
  
  except Exception as e:
    return critical_error(e)
