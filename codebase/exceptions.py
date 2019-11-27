
class ServerlessClientException(Exception):
    def __init__(self, message, http_status='400'):
        super().__init__(message)
        self.http_status = http_status
        self.errors = [message]

class ServerlessException(Exception):
    def __init__(self, message, http_status='500'):
        super().__init__(message)
        self.http_status = http_status
        self.errors = [message]

class QueryStatusUnchangedException(Exception):
    pass

class QueryStatusUnknownException(Exception):
    pass
