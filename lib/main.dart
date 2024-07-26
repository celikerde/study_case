import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucida/providers/state_provider.dart';
import 'package:lucida/providers/theme_provider.dart';
import 'package:lucida/themes.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StateProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider(lightTheme)),
      ],
      child: const HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getThemeData(),
          home: SpeechScreen(),
        );
      },
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Color micColor = Colors.white;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  late FlutterTts _flutterTts;
  final String readyAnswer = 'My name is Luci. Nice to meet you';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  void speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(readyAnswer);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change theme',
          style: TextStyle(color: Colors.black),
        ),
        //Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
        actions: [
          Container(
            width: 200,
            child: SwitchListTile(
                value: themeProvider.getThemeData() == darkTheme,
                onChanged: (value) {
                  themeProvider.setThemeData(value ? darkTheme : lightTheme);
                }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child:
              Icon(color: micColor, _isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: Column(
            children: [
              Text(
                _text,
                style: const TextStyle(fontSize: 32, color: Colors.black),
              ),
              ElevatedButton(
                  onPressed: () => speak(_text), child: Text('Speak'))
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('On status $val');
          //print(Provider.of<StateProvider>(context).changeState(val));
        },
        onError: (val) {
          print('On error $val');
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          micColor = Colors.red;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }
}
