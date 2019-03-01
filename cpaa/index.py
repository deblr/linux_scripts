#!/bin/python
from flask import Flask,send_file
import sys

app = Flask(__name__)

@app.route('/')
def index():
    return send_file('/etc/cpaa/index.html')


if __name__ == '__main__':
    ip=sys.argv[0]
    app.run(host=ip,port=80)