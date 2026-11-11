"""pulse-api: tiny service used as the capstone workload.

Endpoints:
  /         -> hello + which cloud/version is serving
  /health   -> liveness (process is alive)
  /ready    -> readiness (ready to take traffic)
  /metrics  -> Prometheus metrics
"""
import os
import time

from fastapi import FastAPI, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

APP_VERSION = os.getenv("APP_VERSION", "dev")
CLOUD = os.getenv("CLOUD", "local")

REQUESTS = Counter("http_requests_total", "HTTP requests", ["method", "path", "status"])
LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["path"])

app = FastAPI(title="pulse-api", version=APP_VERSION)


@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    path = request.url.path
    if path != "/metrics":
        LATENCY.labels(path).observe(time.perf_counter() - start)
        REQUESTS.labels(request.method, path, str(response.status_code)).inc()
    return response


@app.get("/")
def root():
    return {"service": "pulse-api", "version": APP_VERSION, "cloud": CLOUD}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    return {"status": "ready"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
