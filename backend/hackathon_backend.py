#!/usr/bin/env python3
from flask import Flask, jsonify, request

from hackathon_backend.Pin import Pin, PinType
from hackathon_backend.Vote import Vote

app = Flask(__name__)

# Just get requests
@app.route('/pin', methods=['GET'])
@app.route('/pin/', methods=['GET'])
def get_pins():
    # Deserialize the request body
    body = request.get_json()

    try:
        latitude = float(body['latitude'])
        longitude = float(body['longitude'])
        length = int(body['length'])
        width = int(body['width'])
    except KeyError:
        return jsonify({
            "error": "Missing parameters in request body"
        }), 400
    except ValueError:
        return jsonify({
            "error": "Invalid parameters in request body"
        }), 400

    # Create sample array of pins
    pins = [
        Pin(PinType.GARBAGE, latitude, longitude),
        Pin(PinType.RECYCLE, latitude, longitude),
    ]

    return jsonify([pin.to_map_json() for pin in pins])

@app.route('/pin/<id>', methods=['GET'])
@app.route('/pin/<id>/', methods=['GET'])
def get_pin(id: int):
    Pin(PinType.GARBAGE, 36.06712, -94.17449, votes=1, time_added=0, id=id)

    return jsonify({
        "id": id
    })


@app.route('/pin', methods=['POST'])
@app.route('/pin/', methods=['POST'])
def post_pin():
    # Deserialize the request body
    body = request.get_json()

    try:
        pin_type_string = body['type']
        try:
            pin_type = PinType[body['type']]
        except KeyError:
            return jsonify({
                "error": f"Invalid pin type: {pin_type_string}"
            }), 400

        latitude = float(body['latitude'])
        longitude = float(body['longitude'])
    except KeyError:
        return jsonify({
            "error": "Missing parameters in request body"
        }), 400
    except ValueError:
        return jsonify({
            "error": "Invalid parameters in request body"
        }), 400

    # Create a new pin
    pin = Pin(pin_type, latitude, longitude)

    return jsonify(pin.to_json())


@app.route('/pin/<id>/vote', methods=['GET'])
@app.route('/pin/<id>/vote/', methods=['GET'])
def get_vote(id: int):
    response = {
        "votes": 1
    }

    return jsonify(response)


@app.route('/pin/<id>/vote', methods=['PUT'])
@app.route('/pin/<id>/vote/', methods=['PUT'])
def put_vote(id: int):
    # Deserialize the request body
    body = request.get_json()

    try:
        vote_string = body['vote']
        try:
            vote = Vote(int(vote_string))
        except ValueError:
            return jsonify({
                "error": f"Invalid vote: {vote_string}"
            }), 400
    except KeyError:
        return jsonify({
            "error": "Missing parameters in request body"
        }), 400
    except ValueError:
        return jsonify({
            "error": "Invalid parameters in request body"
        }), 400

    response = {
        "votes": vote.value
    }

    return jsonify(response)


def __main__():
    app.run()


# Run the program
if __name__ == '__main__':
    __main__()
