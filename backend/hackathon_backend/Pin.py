from enum import Enum
import time
import uuid

class PinType(Enum):
    GARBAGE = 1
    RECYCLE = 2

class Pin:
    starting_votes = 1

    def __init__(self, pin_type: PinType, latitude: float, longitude: float, votes: int = starting_votes, time_added: float = time.time(), id = int(uuid.uuid4())):
        self.pin_type = pin_type
        self.latitude = latitude
        self.longitude = longitude
        self.time_added = time_added
        self.votes = votes
        self.id = id


    def __str__(self):
        return f"Pin ({self.pin_type}) created on {self.time_added}:\t{self.latitude}, {self.longitude}"

    def to_json(self):
        return {
            "id": self.id,
            "type": self.pin_type.name,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "createdOn": self.time_added,
            "votes": self.votes
        }

    def to_map_json(self):
        return {
            "id": self.id,
            "type": self.pin_type.name,
            "latitude": self.latitude,
            "longitude": self.longitude,
        }
