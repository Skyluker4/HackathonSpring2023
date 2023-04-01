import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, rootBundle;
import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'pin.dart';
import 'bottom_modal.dart';
import 'package:background_fetch/background_fetch.dart';

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
  Timer timer = Timer(const Duration(seconds: 1), () {});
  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(36.0661969, -94.1737604);

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
    timer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => {getPins(), loadData()});
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
    timer.cancel();
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

  Widget _locateButton() {
    return FloatingActionButton.extended(
      onPressed: _locateScene,
      label: const Text(
        'Locate',
        style: TextStyle(fontSize: 18),
      ),
      icon: const Icon(Icons.location_on),
    );
  }

  Widget _addButton() {
    return FloatingActionButton(
      onPressed: _addScene,
      child: const Icon(Icons.add),
    );
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
              child: _locateButton(),
            ),
          ),
        ),
        // Add button aligned to the bottom right
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            // Simple button
            child: _addButton(),
          ),
        ),
      ],
    );
  }

  Widget _addRecycleButton() {
    return FloatingActionButton.extended(
      // Add recycle bin to the map when pressed
      onPressed: () {
        // Get lat and long of the current position of the middle of the screen
        final controller = googleMapController.future;
        controller.then((value) {
          value.getVisibleRegion().then((value) {
            final lat =
                (value.northeast.latitude + value.southwest.latitude) / 2;
            final long =
                (value.northeast.longitude + value.southwest.longitude) / 2;
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
    );
  }

  Widget _addTrashButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        final controller = googleMapController.future;
        controller.then((value) {
          value.getVisibleRegion().then((value) {
            final lat =
                (value.northeast.latitude + value.southwest.latitude) / 2;
            final long =
                (value.northeast.longitude + value.southwest.longitude) / 2;
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
    );
  }

  Widget _backButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_polylines.isNotEmpty) {
          _polylines.clear();
        }
        _mainScene();
      },
      child: const Icon(Icons.arrow_back),
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
              child: _addRecycleButton(),
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
                  child: _addTrashButton(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _backButton(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget findTrash() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_polylines.isNotEmpty) _polylines.clear();
        computePath(PinType.garbage);
        _locateCamera(PinType.garbage);
      },
      label: const Text(
        'Trash',
        style: TextStyle(fontSize: 18),
      ),
      icon: const Icon(Icons.search),
    );
  }

  Widget findRecycle() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_polylines.isNotEmpty) _polylines.clear();
        computePath(PinType.recycle);
        _locateCamera(PinType.recycle);
      },
      label: const Text(
        'Recycle',
        style: TextStyle(fontSize: 18),
      ),
      icon: const Icon(Icons.search),
    );
  }

  Widget _locatePage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 5),
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width / 2 - 59,
              child: findTrash(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 16),
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width / 2 - 63,
              child: findRecycle(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _backButton(),
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
    return const Align(
      alignment: Alignment.center,
      // Offset the pin by 20 pixels up
      child: Icon(
        Icons.location_on,
        size: 30,
        color: Colors.black,
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
  final List<Polyline> _polylines = <Polyline>[];

  GoogleMapPolyline googleMapPolyline =
      GoogleMapPolyline(apiKey: "AIzaSyCRqFm9BmR_OSO8GL7G6E2CC295MgjDJ28");

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
          snippet: "${pins[i].latitude}, ${pins[i].longitude}",
        ),
        onTap: () => {showBottomModal(context, pins[i])},
      ));
      setState(() {});
    }
  }

  // Calculate the distance between two points with the pythagorian theorem
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final distance = sqrt(pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));
    return distance;
  }

  // Loop over the list of pins and see which one is closest to the user
  // Pass in pin type to filter by
  Pin findClosestPin(PinType? type) {
    late Pin closestPin;
    double closestDistance = double.infinity;
    if (type == PinType.garbage) {
      for (var i = 0; i < _pins.length; i++) {
        if (_pins[i].type == PinType.garbage) {
          final distance = calculateDistance(
            _currentLatLng.latitude,
            _currentLatLng.longitude,
            _pins[i].latitude,
            _pins[i].longitude,
          );

          if (distance < closestDistance) {
            closestPin = _pins[i];
            closestDistance = distance;
          }
        }
      }
    } else {
      for (var i = 0; i < _pins.length; i++) {
        if (_pins[i].type == PinType.recycle) {
          final distance = calculateDistance(
            _currentLatLng.latitude,
            _currentLatLng.longitude,
            _pins[i].latitude,
            _pins[i].longitude,
          );

          if (distance < closestDistance) {
            closestPin = _pins[i];
            closestDistance = distance;
          }
        }
      }
    }

    return closestPin;
  }

  // Match the closest pin to the user with the closest marker
  Marker findClosestMarker(PinType? type) {
    final closestPin = findClosestPin(type);
    late Marker closestMarker;

    for (var i = 0; i < _markers.length; i++) {
      if (_markers[i].markerId.value == closestPin.id.toString()) {
        closestMarker = _markers[i];
      }
    }

    return closestMarker;
  }

  // Focus the camera on the point halfway between the user and the closest pin
  void _locateCamera(PinType? type) {
    final closestPin = findClosestPin(type);

    final lat = (_currentLatLng.latitude + closestPin.latitude) / 2;
    final long = (_currentLatLng.longitude + closestPin.longitude) / 2;

    // Animate the camera to the new position
    // Adjust the zoom level to fit the two points on the screen
    googleMapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, long),
            zoom: 18,
          ),
        ),
      );
    });
  }

  // Draw a line between the user and the closest pin
  computePath(PinType? type) async {
    final arrival = findClosestMarker(type);
    final routeCoords = <LatLng>[];
    LatLng origin = LatLng(_currentLatLng.latitude, _currentLatLng.longitude);
    LatLng end = LatLng(arrival.position.latitude, arrival.position.longitude);
    routeCoords.addAll((await googleMapPolyline.getCoordinatesWithLocation(
        origin: origin, destination: end, mode: RouteMode.walking))!);

    setState(() {
      _polylines.add(Polyline(
          polylineId: const PolylineId('iter'),
          visible: true,
          points: routeCoords,
          width: 6,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });
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
            polylines: Set<Polyline>.of(_polylines),
            onMapCreated: (GoogleMapController controller) async {
              // to control the camera position of the map
              googleMapController.complete(controller);
              _setMapStyle();
            },
          ),
          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
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
          ),
        ],
      ),
    );
  }
}
