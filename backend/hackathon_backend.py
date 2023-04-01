#!/usr/bin/env python3
from flask import Flask, jsonify, request
import psycopg2

from hackathon_backend.Pin import Pin, PinType
from hackathon_backend.Vote import Vote

app = Flask(__name__)

cursor = None


def select_pin_from_id(id: str):
    cursor.execute("SELECT * FROM pins WHERE id = %s", (id,))

    result = cursor.fetchone()

    pin = None

    if result is None:
        raise KeyError("Could not find id.")
    else:
        pin = Pin(id=result[0], pin_type=PinType(result[1]), time_added=result[2], latitude=result[3], longitude=result[4], votes=result[5])

    return pin



@app.route('/pin', methods=['GET'])
@app.route('/pin/', methods=['GET'])
def get_pins():
    # Deserialize the request body
    body = request.get_json()

    try:
        latitude = float(body['latitude'])
        longitude = float(body['longitude'])
        width = float(body['width'])
        height = float(body['height'])
    except KeyError:
        return jsonify({
            "error": "Missing parameters in request body"
        }), 400
    except ValueError:
        return jsonify({
            "error": "Invalid parameters in request body"
        }), 400

    '''
    If needed in the future...
    cursor.execute("""
        SELECT * FROM pins
        WHERE latitude < %s AND latitude > %s AND longitude < %s AND longitude > %s;
    """, (latitude + height, latitude - height, longitude + width, longitude - width,))
    '''

    # Get all pins
    cursor.execute("SELECT id, type, latitude, longitude FROM pins")
    results = cursor.fetchall()

    pins = list()
    for result in results:
        pins.append(Pin(PinType(int(result[1] )), float(result[2]), float(result[3]), id=str(result[0])))

    return jsonify([pin.to_map_json() for pin in pins])

@app.route('/pin/<id>', methods=['GET'])
@app.route('/pin/<id>/', methods=['GET'])
def get_pin(id: str):
    try:
        pin = select_pin_from_id(id)
    except KeyError:
        return "", 404

    return jsonify(pin.to_json())


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

    cursor.execute("""
        INSERT INTO pins (type, timecreated, latitude, longitude, votes)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id;
    """, (pin.pin_type.value, pin.time_added, pin.latitude, pin.longitude, pin.votes))

    # Get id
    id = str(cursor.fetchone()[0])
    pin.id = id

    return jsonify(pin.to_json())


@app.route('/pin/<id>/vote', methods=['GET'])
@app.route('/pin/<id>/vote/', methods=['GET'])
def get_vote(id: str):
    try:
        pin = select_pin_from_id(id)
    except KeyError:
        return "", 404

    response = {
        "votes": pin.votes
    }

    return jsonify(response)


@app.route('/pin/<id>/vote', methods=['PUT'])
@app.route('/pin/<id>/vote/', methods=['PUT'])
def put_vote(id: str):
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

    # Get pin vote
    try:
        pin = select_pin_from_id(id)
    except KeyError:
        return "", 404
    votes = pin.votes + vote.value

    if votes > 0:
        cursor.execute("UPDATE pins SET votes = %s WHERE id = %s", (votes, id))
    else:
        # Delete the pin from the database
        cursor.execute("DELETE FROM pins WHERE id = %s", (id,))

    response = {
            "votes": votes
    }

    return response


def __main__():
    global cursor
    conn = psycopg2.connect(database="hackathon",
                        host="127.0.0.1",
                        user="backend",
                        password="ZvVHJl0E9KAztBhG",
                        port="5432")
    cursor = conn.cursor()

    app.run()


# Run the program
if __name__ == '__main__':
    __main__()
