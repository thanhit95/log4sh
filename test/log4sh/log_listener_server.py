#!/bin/python3
from http.server import HTTPServer, BaseHTTPRequestHandler


class EchoRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        data_len = self.headers.get('Content-Length')
        if not data_len:
            print('Illegal data with zero/null length')
            self.send_response(200)
            self.end_headers()
            return
        data_len = int(data_len)
        # print('data_len:', data_len)
        data = self.rfile.read(data_len).decode()
        print('Received data:', data)
        self.send_response(200)
        self.end_headers()


if __name__ == '__main__':
    PORT = 8080
    print(f'Echo Server is listening on 0.0.0.0:{PORT}')
    server = HTTPServer(('', PORT), EchoRequestHandler)
    server.serve_forever()
