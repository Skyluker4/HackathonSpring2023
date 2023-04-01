import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hackathon/pin.dart';
import 'package:intl/intl.dart';

class VotingWidget extends State<StatefulWidget> {
  Color _upColor = Colors.grey;
  Color _downColor = Colors.grey;

  // Constructor that takes in a Pin object
  final Pin pin;
  int votes;

  VotingWidget({required this.pin}) : votes = pin.votes ?? 0;

  @override
  Widget build(context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm a');

    return Container(
      height: 220,
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 0.0, // has the effect of extending the shadow
            )
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              pin.type == PinType.garbage ? "Garbage Can" : "Recycling Bin",
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Added on ${formatter.format(pin.createdOn ?? DateTime(0))}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // Size each element evenly across the row
              mainAxisSize: MainAxisSize.max,
              // Make the row as wide as possible
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.thumb_down, color: _downColor),
                  iconSize: 40,
                  onPressed: () {
                    if (pin.votes == 1) {
                      // Remove the marker from the array
                    }
                    sendVote(pin.id, -1);
                  },
                ),
                Column(
                  children: [
                    Text(
                      "$votes",
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      "votes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.thumb_up, color: _upColor),
                  iconSize: 40,
                  onPressed: () {
                    sendVote(pin.id, 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<Pin> getPin(String id) async {
  // Make a request to the server for pin details
  final response = await http
      .get(Uri.parse('https://hackathon.lukesimmons.codes/api/v1/pin/$id'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final pin = Pin.fromJson(data);
    return pin;
  } else {
    throw Exception('Failed to load pins');
  }
}

Future<void> sendVote(String id, int vote) async {
  final response = await http.put(
    Uri.parse('https://hackathon.lukesimmons.codes/api/v1/pin/$id/vote'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Response-Type': 'application/json',
    },
    body: jsonEncode(<String, int>{
      'vote': vote,
    }),
  );

  if (response.statusCode == 200) {
    // Success
  } else {
    throw Exception('Failed to send vote');
  }
}

showBottomModal(context, Pin pin) async {
  // Make a request to the server for pin details
  pin = await getPin(pin.id);

  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return VotingWidget(pin: pin).build(context);
      });
}
