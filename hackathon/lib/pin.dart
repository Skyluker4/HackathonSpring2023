enum PinType { garbage, recycle }

class Pin {
  final String id;
  final double latitude;
  final double longitude;
  final PinType type;
  final DateTime? createdOn;
  final int? votes;

  Pin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.createdOn,
    this.votes,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      type: json['type'] == 'GARBAGE'
          ? PinType.garbage
          : json['type'] == 'RECYCLE'
              ? PinType.recycle
              : throw Exception('Invalid PinType'),
      createdOn: json['createdOn'] == null
          ? null
          : DateTime.parse(json['createdOn'] as String),
      votes: json['votes'] as int?,
    );
  }
}
