from enum import Enum
import time

class PinType(Enum):
    GARBAGE = 1
    RECYCLING = 2

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