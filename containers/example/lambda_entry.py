def hello_world(event, context):
  try:
    from codebase.api.hello_world import ApiHelloWorld
    
    hw = ApiHelloWorld(event)
    return hw.response
  
  except Exception as e:
    raise e
