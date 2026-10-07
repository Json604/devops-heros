import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse
from .calculator import add, subtract, multiply, divide

OPERATIONS = {"add": add, "subtract": subtract, "multiply": multiply, "divide": divide}

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        request = urlparse(self.path)
        if request.path == "/health":
            return self.respond(200, {"status": "UP"})
        if request.path != "/calculate":
            return self.respond(404, {"error": "Not found"})
        params = parse_qs(request.query)
        try:
            operation = OPERATIONS[params["operation"][0]]
            result = operation(float(params["a"][0]), float(params["b"][0]))
            self.respond(200, {"result": result})
        except (KeyError, ValueError, ZeroDivisionError, OverflowError):
            self.respond(400, {"error": "Use operation=add|subtract|multiply|divide and numeric a,b; divisor must be nonzero"})

    def respond(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
