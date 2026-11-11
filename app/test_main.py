from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["service"] == "pulse-api"


def test_health_and_ready():
    assert client.get("/health").json() == {"status": "ok"}
    assert client.get("/ready").json() == {"status": "ready"}


def test_metrics_counts_requests():
    client.get("/")
    body = client.get("/metrics").text
    assert "http_requests_total" in body
