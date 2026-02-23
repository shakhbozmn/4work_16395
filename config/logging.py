import os
from logging.config import dictConfig

# Logging configuration for Django application


def get_logging_config(environment='production'):
    """
    Get logging configuration based on environment.
    
    Args:
        environment: 'development' or 'production'
    
    Returns:
        dict: Logging configuration dictionary
    """
    
    if environment == 'development':
        return {
            'version': 1,
            'disable_existing_loggers': False,
            'formatters': {
                'verbose': {
                    'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
                    'style': '{',
                },
                'simple': {
                    'format': '{levelname} {message}',
                    'style': '{',
                },
            },
            'handlers': {
                'console': {
                    'class': 'logging.StreamHandler',
                    'formatter': 'verbose',
                },
            },
            'root': {
                'handlers': ['console'],
                'level': 'INFO',
            },
            'loggers': {
                'django': {
                    'handlers': ['console'],
                    'level': os.environ.get('DJANGO_LOG_LEVEL', 'INFO'),
                    'propagate': False,
                },
                'django.db.backends': {
                    'handlers': ['console'],
                    'level': 'DEBUG',
                    'propagate': False,
                },
                'accounts': {
                    'handlers': ['console'],
                    'level': 'DEBUG',
                    'propagate': False,
                },
                'marketplace': {
                    'handlers': ['console'],
                    'level': 'DEBUG',
                    'propagate': False,
                },
            },
        }
    
    # Production logging configuration
    return {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'verbose': {
                'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
                'style': '{',
            },
            'simple': {
                'format': '{levelname} {message}',
                'style': '{',
            },
            'json': {
                '()': 'pythonjsonlogger.jsonlogger.JsonFormatter',
                'format': '%(asctime)s %(name)s %(levelname)s %(message)s',
            },
        },
        'filters': {
            'require_debug_true': {
                '()': 'django.utils.log.RequireDebugTrue',
            },
            'require_debug_false': {
                '()': 'django.utils.log.RequireDebugFalse',
            },
        },
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'formatter': 'verbose',
                'filters': ['require_debug_true'],
            },
            'file': {
                'class': 'logging.handlers.RotatingFileHandler',
                'filename': os.path.join(os.environ.get('LOG_DIR', '/var/log/django'), 'django.log'),
                'maxBytes': 1024 * 1024 * 10,  # 10 MB
                'backupCount': 10,
                'formatter': 'verbose',
                'filters': ['require_debug_false'],
            },
            'error_file': {
                'class': 'logging.handlers.RotatingFileHandler',
                'filename': os.path.join(os.environ.get('LOG_DIR', '/var/log/django'), 'django_error.log'),
                'maxBytes': 1024 * 1024 * 10,  # 10 MB
                'backupCount': 10,
                'formatter': 'verbose',
                'level': 'ERROR',
                'filters': ['require_debug_false'],
            },
        },
        'root': {
            'handlers': ['console', 'file', 'error_file'],
            'level': 'INFO',
        },
        'loggers': {
            'django': {
                'handlers': ['console', 'file', 'error_file'],
                'level': os.environ.get('DJANGO_LOG_LEVEL', 'INFO'),
                'propagate': False,
            },
            'django.db.backends': {
                'handlers': ['console', 'file'],
                'level': 'WARNING',
                'propagate': False,
            },
            'django.security': {
                'handlers': ['console', 'file', 'error_file'],
                'level': 'WARNING',
                'propagate': False,
            },
            'accounts': {
                'handlers': ['console', 'file', 'error_file'],
                'level': 'INFO',
                'propagate': False,
            },
            'marketplace': {
                'handlers': ['console', 'file', 'error_file'],
                'level': 'INFO',
                'propagate': False,
            },
        },
    }


def setup_logging(environment='production'):
    """
    Setup logging configuration for Django.
    
    Args:
        environment: 'development' or 'production'
    """
    config = get_logging_config(environment)
    dictConfig(config)
