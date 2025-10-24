from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics
app = Flask(__name__)
metrics = PrometheusMetrics(app) # This adds the /metrics endpoint for Prometheus
@app.route('/')
def hello():
    return "The Final App is working! Metrics are being generated.\\n"
