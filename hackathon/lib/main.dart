import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _scene = 0;
  String _darkMapStyle = '';
  String _lightMapStyle = '';

  final Completer<GoogleMapController> googleMapController = Completer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/json/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/json/light.json');
  }

  Future _setMapStyle() async {
    final controller = await googleMapController.future;
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (theme == Brightness.dark)
      controller.setMapStyle(_darkMapStyle);
    else
      controller.setMapStyle(_lightMapStyle);
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

  CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(20.5937, 78.9629));

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
                  'Garbage Bin',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.delete),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _back() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Back button not visible if counter is 0
        if (_scene != 0)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            compassEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              // to control the camera position of the map
              googleMapController.complete(controller);
              _setMapStyle();
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                // Switch between scenes
                if (_scene == 0) _mainPage(),
                if (_scene == 1) _addPage(),
                if (_scene == 2) _back(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
