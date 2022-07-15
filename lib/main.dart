import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'theme_config.dart';

void main() {
  runApp(const MyApp());
}

bool _isDark = false;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final initTheme = _isDark ? darkTheme : lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, myTheme) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: myTheme,
          home: const MyHomePage(title: 'Telegram'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StateMachineController? _controller;
  Artboard? _riveArtboard;
  SMIInput<bool>? isDark;
  bool get isPlaying => _controller?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/anim/telegramswitch.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        final artboard = file.artboardByName('Main Artboard');
        var _controller =
            StateMachineController.fromArtboard(artboard!, 'State Machine 1');

        if (_controller != null) {
          isDark = _controller.findInput('isDark');
          isDark!.value = _isDark;
          artboard.addController(_controller);
        }
        setState(() => {
              _riveArtboard = artboard,
            });
      },
    );
  }

  void changTheme() async {
    setState(() {
      debugPrint(_isDark.toString());
      _isDark = !_isDark;
      isDark!.value = !isDark!.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                color: Colors.cyan[700],
                child: Align(
                  alignment: Alignment.topRight,
                  child: ThemeSwitcher(builder: (context) {
                    return IconButton(
                      onPressed: () {
                        changTheme();
                        ThemeSwitcher.of(context).changeTheme(
                            theme: _isDark ? darkTheme : lightTheme);
                      },
                      icon: _riveArtboard == null
                          ? const SizedBox()
                          : Rive(
                              artboard: _riveArtboard!,
                            ),
                    );
                  }),
                ),
              ),
              Expanded(child: Container())
            ],
          ),
        ),
      ),
      body: Container(),
    );
  }
}
