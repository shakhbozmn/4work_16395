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
timeout = 120
keepalive = 2

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"

# Process naming
proc_name = "4work-[{proc_num}]"

# Server hooks
def when_ready(server):
    print("Gunicorn server is ready. Spawning workers")

def worker_int(worker):
    print(f"Worker spawned (pid: {worker.pid})")

def worker_abort(worker):
    print(f"Worker received INT or QUIT signal (pid: {worker.pid})")

def pre_fork(server, worker):
    pass

def post_fork(server, worker):
    pass

def pre_exec(server):
    print("Forked child, re-executing.")

def child_exit(server, worker):
    print("Child exited.")
