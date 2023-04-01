import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'pin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathon App',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.lightBlue,
          secondary: Colors.orangeAccent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Hackathon App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _scene = 0;
  String _darkMapStyle = '';
  String _lightMapStyle = '';

  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(27.671332124757402, 85.3125417636781);

  final Completer<GoogleMapController> googleMapController = Completer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
    _getLocation();
  }

  _getLocation() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    var pp = await Geolocator.checkPermission();
    // if (pp.name == LocationPermission.always) {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    setState(() {});
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/json/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/json/light.json');
  }

  Future _setMapStyle() async {
    final controller = await googleMapController.future;
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (theme == Brightness.dark) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(_lightMapStyle);
    }
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _mainScene() {
    setState(() {
      _scene = 0;
    });
  }

  void _addScene() {
    setState(() {
      _scene = 1;
    });
  }

  void _locateScene() {
    setState(() {
      _scene = 2;
    });
  }

  Widget _mainPage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Locate button aligned to the bottom left
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            // SizedBox is used to set the size of the button
            child: SizedBox(
              height: 56,
              // MediaQuery is used to get the width of the screen
              // and subtract 112 to get the width of the button
              width: MediaQuery.of(context).size.width - 112,
              // extended is used to make the button wider
              child: FloatingActionButton.extended(
                onPressed: _locateScene,
                label: const Text(
                  'Locate',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.location_on),
              ),
            ),
          ),
        ),
        // Add button aligned to the bottom right
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            // Simple button
            child: FloatingActionButton(
              onPressed: _addScene,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20),
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width - 112,
              child: FloatingActionButton.extended(
                onPressed: _mainScene,
                label: const Text(
                  'Recycle Bin',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.recycling),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                  height: 56,
                  width: MediaQuery.of(context).size.width - 112,
                  child: FloatingActionButton.extended(
                    onPressed: _mainScene,
                    label: const Text(
                      'Compost Bin',
                      style: TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.grass),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: FloatingActionButton(
                  onPressed: _mainScene,
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _locatePage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: FloatingActionButton(
              onPressed: _mainScene,
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recenter() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 132, right: 23),
        child: IconButton(
          onPressed: () {
            googleMapController.future.then((controller) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _currentLatLng,
                    zoom: 18,
                  ),
                ),
              );
            });
          },
          icon: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  Future<List<Pin>> getPins() async {
    final response = await http
        .get(Uri.parse('http://hackathon.lukesimmons.codes/api/v1/pin'));

    List<Pin> pins = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var i = 0; i < data.length; i++) {
        final pin = Pin.fromJson(data[i]);
        pins.add(pin);
      }
    } else {
      throw Exception('Failed to load pins');
    }

    return pins;
  }

  @override
  Widget build(BuildContext context) {
    var pins = getPins();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition:
                CameraPosition(zoom: 18, target: _currentLatLng),
            compassEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              // to control the camera position of the map
              setState(() {
                googleMapController.complete(controller);
              });
              _setMapStyle();
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                // Switch between scenes
                if (_scene == 0) _mainPage(),
                if (_scene == 1) _addPage(),
                if (_scene == 2) _locatePage(),
                // Recenter button
                _recenter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
