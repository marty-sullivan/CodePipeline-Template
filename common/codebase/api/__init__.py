import json
from boto3.session import Session
from codebase.exceptions import ServerlessClientException

# aws = Session()
# firehose = aws.client('firehose')

class ProxyApi(object):
  
  def __init__(self, event):
    self.event = event
    self.method = event['requestContext']['httpMethod'].upper()
    self.path = event['path'].strip('/').split('/')
    
    if self.method in ['POST']:
      try:
        self.params = json.loads(event['body'])
        
      except ValueError:
        raise ServerlessClientException('POST Body Must be valid JSON')
    
    elif self.method in ['GET']:
      self.params = event['pathParameters']
      
      self.qs = event['queryStringParameters'] if 'queryStringParameters' in event and event['queryStringParameters'] else { }
      self.mvqs = event['multiValueQueryStringParameters'] if 'multiValueQueryStringParameters' in event and event['multiValueQueryStringParameters'] else { }
      