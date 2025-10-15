from flask import Flask, Response
from prometheus_client import generate_latest, Counter

app = Flask(__name__)
c = Counter('my_counter', 'An example counter')

@app.route("/")
def index():
    # Increment the counter every time the main page is visited
    c.inc()
    return "App is running! Metrics are at /metrics"

@app.route("/health")
def health():
    return {"status": "UP"}

@app.route("/metrics")
def metrics():
    # Manually create a Response object and set the correct Content-Type.
    # This is more robust and forces the correct format for Prometheus.
    return Response(generate_latest(), mimetype='text/plain; version=0.0.4')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
