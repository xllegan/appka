class DataBaseURLNotFound(Exception):
    """DataBase URL cannot be parsed from .env file"""

class SecretKeyNotFound(Exception):
    """Secret Key cannot be parsed from .env file"""

class InvalidSecretKey(Exception):
    """Secret Key was parsed, but it is invalid"""

class InvalidKeyType(Exception):
    """You indicated wrong key type"""