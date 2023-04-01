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
  int _scene = 0;

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
        // The body is defined as a SafeArea
        body: SafeArea(
          // Two rows are defined
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // The first row is defined as a Row
            // It contains a Text widget and a IconButton
            children: [
              // First row is aligned to the top of the SafeArea
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button not visible if counter is 0
                  if (_scene != 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _mainScene,
                    ),
                  // Options button (not implemented)
                  /*IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),*/
                ],
              ),
              // The second row is aligned to the bottom of the SafeArea
              // Only visible if _scene is 0
              if (_scene == 0)
                Row(
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
                ),
              // Column containing the add scene
              // Only visible if _scene is 1
              if (_scene == 1)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Two Buttons stacked on top of each other
                    // Both are aligned to the center of the screen
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          height: 56,
                          width: MediaQuery.of(context).size.width - 112,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            label: const Text(
                              'Recycle Bin',
                              style: TextStyle(fontSize: 18),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          height: 56,
                          width: MediaQuery.of(context).size.width - 112,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            label: const Text(
                              'Trash Can',
                              style: TextStyle(fontSize: 18),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ));
  }
}
