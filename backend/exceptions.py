class DataBaseURLNotFound(Exception):
    """DataBase URL cannot be parsed from .env file"""

class SecretKeyNotFound(Exception):
    """Secret Key cannot be parsed from .env file"""

class InvalidSecretKey(Exception):
    """Secret Key was parsed, but it is invalid"""

class InvalidKeyType(Exception):
    """You indicated wrong key type"""

class UserAlreadyExists(Exception):
    """User with such data already exists in DB"""

class UserNotFound(Exception):
    """User with some id not found"""

class APIKeyNotFound(Exception):
    """API Key not found"""