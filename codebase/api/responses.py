import json
import logging
from codebase import get_logger, json_handler

DEFAULT_CACHE_CONTROL = 'no-cache, no-store, must-revalidate'

logger = get_logger()

def binary_response(Body, ContentType, StatusCode='200', CacheControl=DEFAULT_CACHE_CONTROL):
  resp = dict(
    statusCode=StatusCode,
    headers={
      'Cache-Control': CacheControl,
      'Content-Type': ContentType,
    },
    body=Body,
    isBase64Encoded=True,
  )
  
  return resp

def http_response(Body='{ }', StatusCode='200', ContentType='application/json', CacheControl=DEFAULT_CACHE_CONTROL):
    resp = dict(
      statusCode=StatusCode,
      headers={
        'Cache-Control': CacheControl,
        'Content-Type': ContentType,
      },
      body=Body + '\n',
    )

    return resp
    
def client_error(e):
    errors = json.dumps(e.errors, default=json_handler)
    logger.warning('Client Error ' + errors)
    
    return http_response(
      Body=json.dumps({ 'errors': errors }, default=json_handler),
      StatusCode=e.http_status, 
    )

def server_error(e):
    errors = json.dumps(e.errors, default=json_handler)
    logger.error('Server Error ' + errors)
    logging.exception('Server Error Traceback:')
    
    return http_response(
      Body=json.dumps({ 'errors': errors }, default=json_handler),
      StatusCode=e.http_status,
    )

def critical_error(e):
    logging.exception('Critical Error:')
    logger.critical(e)
    
    return http_response(
      Body=json.dumps({ 'errors': ['SERVER_ERROR'] }, default=json_handler),
      StatusCode='500', 
    )
