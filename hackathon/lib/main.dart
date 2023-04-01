import 'package:flutter/material.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      // Two buttons in the same row
      // Buttons are aligned to the left and right of the screen
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Reset button
          // Aligns the button to the left with a padding of 35
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 35),
              // SizedBox is used to set the size of the button
              child: SizedBox(
                // The height of the button is 56
                height: 56,
                // The width of the button is constrained to the increment button
                width: MediaQuery.of(context).size.width - 112,
                child: FloatingActionButton.extended(
                  onPressed: _resetCounter,
                  // The label of the button is 'Locate'
                  // The font size of the label is 20
                  label: const Text(
                    'Locate',
                    style: TextStyle(fontSize: 18),
                  ),
                  icon: const Icon(Icons.location_on),
                ),
              ),
            ),
          ),
          // Increment button
          // Aligns the button to the right of the screen
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
