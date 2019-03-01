#!/bin/python
from flask import Flask,send_file
import sys

app = Flask(__name__)

@app.route('/')
def index():
    return send_file('/web/pyweb/index.html')


if __name__ == '__main__':
    ip=sys.argv[1]
    app.run(host=ip,port=80)