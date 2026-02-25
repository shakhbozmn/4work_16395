import multiprocessing

# Server socket
bind = "0.0.0.0:8000"

# Workers
workers = multiprocessing.cpu_count() * 2 + 1

# Worker class
worker_class = "sync"

# Worker connections
worker_connections = 1000

# Max requests
max_requests = 1000
max_requests_jitter = 50

# Timeout
timeout = 30
keepalive = 2

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"

# Process naming
proc_name = "4work-[%(proc_num)s]"

preload_app = True