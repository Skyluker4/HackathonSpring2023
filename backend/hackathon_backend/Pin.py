from enum import Enum
import time

class PinType(Enum):
    GARBAGE = 1
    RECYCLE = 2

class Pin:
    starting_votes = 1

    def __init__(self, pin_type: PinType, latitude: float, longitude: float):
        self.pin_type = pin_type
        self.latitude = latitude
        self.longitude = longitude

        # Add the time this pin was added as a Unix timestamp
        self.time_added = time.time()

        # Create a unique ID for this pin
        self.id = hash((self.pin_type, self.latitude, self.longitude, self.time_added))

        self.votes = Pin.starting_votes

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
