#!/usr/bin/env python3
from flask import Flask, jsonify, request

from hackathon_backend.Pin import Pin, PinType

app = Flask(__name__)

@app.route('/pin')
def get_pins():
    # Create sample array of pins
    pins = [
        Pin(PinType.GARBAGE, 37.7749, -122.4194),
        Pin(PinType.GARBAGE, 37.7749, -122.4194),
        Pin(PinType.RECYCLE, 37.7749, -122.4194),
    ]

    return jsonify([pin.to_map_json() for pin in pins])

@app.route('/pin/{id}')
def get_pin():
    return jsonify("")


@app.route('/pin{id}/vote')
def put_vote():
    return ""


def __main__():
    app.run()


# Run the program
if __name__ == '__main__':
    __main__()
