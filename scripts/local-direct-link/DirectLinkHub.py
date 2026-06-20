from __future__ import annotations

import datetime as _dt
import http.server
import pathlib
import re
import socketserver
import sys


ROOT = pathlib.Path(__file__).resolve().parent
INBOX = ROOT / "inbox"


class DirectLinkHandler(http.server.SimpleHTTPRequestHandler):
    server_version = "DirectLinkHub/1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self) -> None:
        if self.path in {"/health", "/healthz"}:
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"direct-link-hub ok\n")
            return

        super().do_GET()

    def do_POST(self) -> None:
        if self.path not in {"/report", "/status"}:
            self.send_error(404, "Use /report for direct-link status posts")
            return

        length_header = self.headers.get("Content-Length")
        try:
            length = int(length_header or "0")
        except ValueError:
            self.send_error(400, "Invalid Content-Length")
            return

        if length > 1024 * 1024:
            self.send_error(413, "Report too large")
            return

        body = self.rfile.read(length)
        now = _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        client = re.sub(r"[^0-9A-Za-z_.-]", "_", self.client_address[0])
        INBOX.mkdir(exist_ok=True)
        path = INBOX / f"{now}-{client}.txt"
        path.write_bytes(body)

        self.send_response(201)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(f"stored {path.name}\n".encode("utf-8"))

    def log_message(self, format: str, *args) -> None:
        timestamp = _dt.datetime.now().isoformat(timespec="seconds")
        sys.stderr.write(f"{timestamp} {self.client_address[0]} {format % args}\n")


def main() -> None:
    host = "10.77.77.1"
    port = 8787
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer((host, port), DirectLinkHandler) as httpd:
        print(f"DirectLinkHub serving {ROOT} at http://{host}:{port}/", flush=True)
        httpd.serve_forever()


if __name__ == "__main__":
    main()
