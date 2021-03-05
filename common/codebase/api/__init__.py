from base64 import b64encode
from codebase import Root
from datetime import datetime, timezone
from os import environ
import json
import logging

class ApiRoot(Root):
  
  def __init__(self, event):
    super().__init__()
    
    self.event = event
    self.method = self.event['requestContext']['httpMethod'].upper()
    self.path = self.event['path'].strip('/').split('/')
    
    self.long_cache = 'max-age=31556926'
    self.status_code = '200'
    self.body = ''
    
    self.headers = {
      # 'access-control-allow-origin': '*',
      'cache-control': 'no-cache, no-store, must-revalidate',
      'content-type': 'application/json',
    }
    
    if self.method in ['POST']:
        self.post_params = json.loads(event['body'])
        
    if self.method in ['GET', 'POST']:
      self.get_params = event['pathParameters']
      self.query_params = event['queryStringParameters'] if 'queryStringParameters' in event and event['queryStringParameters'] else { }
      self.mv_query_params = event['multiValueQueryStringParameters'] if 'multiValueQueryStringParameters' in event and event['multiValueQueryStringParameters'] else { }
  
  def get_binary_response(self):
    self.body = b64encode(self.body).decode('utf-8')
    
    resp = dict(
      statusCode=self.status_code,
      headers=self.headers,
      body=self.body,
      isBase64Encoded=True,
    )
    
    return resp
  
  def get_text_response(self):
    resp = dict(
      statusCode=self.status_code,
      headers=self.headers,
      body=self.body + '\n',
    )
    
    return resp
  
  def get_client_error_response(self, e):
    self.logger.warning('Client Error: ' + e.message)
    
    self.status_code = e.status_code
    
    self.body = json.dumps(dict(
      message=e.message,
    ), default=self.json_handler)
    
    return self.get_text_response()
    
  def get_server_error_response(self, e):
    self.logger.error('Server Error: ' + e.message)
    logging.exception('Server Error Traceback:')
    
    self.status_code = e.status_code
    
    self.body = json.dumps(dict(
      message=e.message,
    ), default=self.json_handler)
    
    return self.get_text_response()
  
  def get_critical_error_response(self, e):
    self.logger.error('Uncaught Exception: ' + e.message)
    logging.exception('Traceback:')
    
    self.status_code = '500'
    
    self.body = json.dumps(dict(
      message='SERVER_ERROR',
    ), default=self.json_handler)
    
    return self.get_text_response()

  def get_redirect_response(self, redirect_path, binary=True):
    self.status_code = '302'
    self.headers['Location'] = redirect_path
    
    if binary:
      self.body = ''.encode('utf-8')
      return self.get_binary_response()
    
    else:
      self.body = ''
      return self.get_text_response()

  def get_access_denied_error_response(self, binary=True):
    self.status_code = '403'
    
    self.body = json.dumps(dict(
      message='ACCESS_DENIED',
    ), default=self.json_handler)
    
    if binary:
      self.body = self.body.encode('utf-8')
      return self.get_binary_response()
      
    else:
      return self.get_text_response()
    
  def get_not_found_error_response(self, binary=True):
    self.status_code = '404'
    
    self.body = json.dumps(dict(
      message='NOT_FOUND',
    ), default=self.json_handler)
    
    if binary:
      self.body = self.body.encode('utf-8')
      return self.get_binary_response()
      
    else:
      return self.get_text_response()
    