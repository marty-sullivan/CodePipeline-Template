from boto3.session import Session
from botocore.config import Config
from datetime import datetime, timezone
from decimal import Decimal
from os import environ, makedirs, path
from sys import stdout
from tempfile import gettempdir
import json
import logging
import subprocess
import warnings

if 'AWS_LAMBDA_FUNCTION_NAME' not in environ:
  log_handler = logging.StreamHandler(stdout)
  formatter = logging.Formatter('[%(levelname)s] %(threadName)s %(asctime)s %(message)s')
  log_handler.setFormatter(formatter)
  
else:
  log_handler = None

class Root(object):
  
  def __init__(self):
    self.entry_time = datetime.utcnow().replace(tzinfo=timezone.utc)
    self.logger = self.create_logger()
    self.application = environ['APPLICATION']
    self.environment = environ['ENVIRONMENT']
    self.task_root = environ['TASK_ROOT'] if 'TASK_ROOT' in environ else environ['LAMBDA_TASK_ROOT']
    self.persistent_dir = self.get_persistent_dir()
    self.transient_dir = self.get_transient_dir()
    self.tmpfs_dir = self.get_tmpfs_dir() if 'AWS_LAMBDA_FUNCTION_NAME' not in environ else self.transient_dir
    
    self.aws = Session()

  def create_logger(self):
    warnings.filterwarnings('ignore')
    
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    
    if log_handler:
      logger.addHandler(log_handler)
    
    logging.getLogger('boto').setLevel(logging.WARN)
    logging.getLogger('boto3').setLevel(logging.WARN)
    logging.getLogger('botocore').setLevel(logging.WARN)
    logging.getLogger('requests').setLevel(logging.WARN)
    logging.getLogger('s3transfer').setLevel(logging.WARN)
    logging.getLogger('urllib3').setLevel(logging.WARN)
    
    return logger 
        
  def get_persistent_dir(self):
    persistent_dir = path.join(path.abspath(path.sep), 'mnt', 'persistent')
    return persistent_dir
  
  def get_tmpfs_dir(self):
    tmpfs_dir = path.join(path.abspath(path.sep), 'mnt', 'tmpfs')
    makedirs(tmpfs_dir, exist_ok=True)
    
    return tmpfs_dir
  
  def get_transient_dir(self):
    transient_dir = path.join(gettempdir())
    makedirs(transient_dir, exist_ok=True)
    
    return transient_dir
  
  def json_handler(self, o):
    if isinstance(o, datetime):
      return o.isoformat()
    elif isinstance(o, Decimal):
      return float(o)
    else:
      self.logger.warning('Unknown Type in json_handler: ' + str(o))
      return str(o)
  
  def nearest(self, items, pivot):
    return min(items, key=lambda x: abs(x - pivot))
  
  def run_shell_command(self, command):
    self.logger.info('Running Command {0}...'.format(command))
    
    p = subprocess.Popen(
      command,
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      shell=True,
    )
    
    output, errors = p.communicate()
    
    self.logger.info(output)
    self.logger.warning(errors)
    
    return output, errors
  