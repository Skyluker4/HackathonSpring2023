import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'pin.dart';
import 'bottom_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
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
  bool plusSelected = false;

  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(27.671332124757402, 85.3125417636781);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  final Completer<GoogleMapController> googleMapController = Completer();

  // Custom icons for the markers
  late final BitmapDescriptor trashIcon;
  late final BitmapDescriptor recycleIcon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
    _getLocation();
    loadData();

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/trash-resize.png')
        .then((onValue) {
      trashIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/recycle-resize.png')
        .then((onValue) {
      recycleIcon = onValue;
    });
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
    plusSelected = true;
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
        // Add a button and animate sliding from the bottom up when created
        AnimatedAlign(
          // If plus selected is true the button will be animated from the bottom moving up
          // If plus selected is false the button will be animated from the top moving down
          
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20),
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width - 112,
              child: FloatingActionButton.extended(
                // Add recycle bin to the map when pressed
                onPressed: () {
                  // Get lat and long of the current position of the middle of the screen
                  final controller = googleMapController.future;
                  controller.then((value) {
                    value.getVisibleRegion().then((value) {
                      final lat = (value.northeast.latitude +
                              value.southwest.latitude) /
                          2;
                      final long = (value.northeast.longitude +
                              value.southwest.longitude) /
                          2;
                      // Add the marker to the map
                      sendPin(lat, long, 'RECYCLE');
                    });
                  });
                  _mainScene();
                },
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
                    onPressed: () {
                      final controller = googleMapController.future;
                      controller.then((value) {
                        value.getVisibleRegion().then((value) {
                          final lat = (value.northeast.latitude +
                                  value.southwest.latitude) /
                              2;
                          final long = (value.northeast.longitude +
                                  value.southwest.longitude) /
                              2;
                          // Add the marker to the map
                          sendPin(lat, long, 'GARBAGE');
                        });
                      });
                      _mainScene();
                    },
                    label: const Text(
                      'Trash Bin',
                      style: TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.delete),
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

  Widget _centerPin() {
    return Align(
      alignment: Alignment.center,
      // Offset the pin by 20 pixels up
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: const Icon(
          Icons.location_on,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<List<Pin>> getPins() async {
    final response = await http
        .get(Uri.parse('https://hackathon.lukesimmons.codes/api/v1/pin'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var i = 0; i < data.length; i++) {
        final pin = Pin.fromJson(data[i]);
        _pins.add(pin);
      }
    } else {
      throw Exception('Failed to load pins');
    }

    return _pins;
  }

  final List<Marker> _markers = <Marker>[];
  final List<Pin> _pins = <Pin>[];

  loadData() async {
    final pins = await getPins();
    for (var i = 0; i < pins.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(pins[i].id.toString()),
        position: LatLng(pins[i].latitude, pins[i].longitude),
        // Custom icons for PinType.recycle and PinType.trash
        icon: pins[i].type == PinType.recycle ? recycleIcon : trashIcon,
        infoWindow: InfoWindow(
          title: pins[i].type == PinType.recycle ? 'Recycle Bin' : 'Trash Bin',
          snippet: pins[i].id,
        ),
        onTap: () => {showBottomModal(context)},
      ));
      setState(() {});
    }
  }

  // Send data to the server when a new pin is added
  Future<List<Pin>> sendPin(double lat, double long, String type) async {
    final response = await http.post(
      Uri.parse('https://hackathon.lukesimmons.codes/api/v1/pin'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'latitude': lat,
        'longitude': long,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pin = Pin.fromJson(data);
      _pins.add(pin);
    } else {
      throw Exception('Failed to add pin');
    }

    loadData();

    return _pins;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) async {
              // to control the camera position of the map
              googleMapController.complete(controller);
              _setMapStyle();
            },
          ),
          //Add pins to map
          SafeArea(
            child: Stack(
              children: [
                // Switch between scenes
                if (_scene == 0) _mainPage(),
                if (_scene == 1) _addPage(),
                if (_scene == 1) _centerPin(),
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
