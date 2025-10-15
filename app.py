from flask import Flask
from prometheus_client import generate_latest, Counter

app = Flask(__name__)
c = Counter('my_counter', 'An example counter')

@app.route("/health")
def health():
    return {"status": "UP"}

@app.route("/metrics")
def metrics():
    c.inc()
    return generate_latest(c)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
