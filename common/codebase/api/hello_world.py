from codebase.api import ApiRoot
from urllib.parse import unquote
import json

class ApiHelloWorld(ApiRoot):
  
  def __init__(self, event):
    super().__init__(event)
    
    message = unquote(self.get_params['message'])
    
    self.headers['x-hello'] = 'world'
    
    self.body = json.dumps(dict(
      hello='world',
      message=message,
    ))
    
    self.response = self.get_text_response()
    