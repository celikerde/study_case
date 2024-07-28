import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucida/providers/state_provider.dart';
import 'package:lucida/providers/theme_provider.dart';
import 'package:lucida/themes.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

import 'dart:developer' as devtools show log;

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
          home: const SpeechScreen(),
        );
      },
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  String _text = '';
  bool _isListening = false;
  bool _isSpeaking = false;
  Color micColor = Colors.blue;
  double _confidence = 1.0;

  final String _readyAnswer1 = 'My name is Luci. Nice to meet you';
  String readyAnswer2 = 'I am fine. How about you?';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeechAndTts();
  }

  Future<void> _initializeSpeechAndTts() async {
    await _speech.initialize();
    await _flutterTts.setLanguage("en-US");
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stateProvider = Provider.of<StateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucida AI'),
        backgroundColor: Colors.amber,
        actions: [
          SizedBox(
            width: 200,
            child: SwitchListTile(
                value: themeProvider.getThemeData() == darkTheme,
                onChanged: (value) {
                  themeProvider.setThemeData(value ? darkTheme : lightTheme);
                }),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _text,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(96.0),
            child: Center(child: Text(stateProvider.getState)),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () async {
            if (_isListening) {
              await _stopListening();
              await _speaking(_readyAnswer1);
              if (stateProvider.getState != "Answering...") {
                _flutterTts.setCompletionHandler(() {
                  stateProvider.assignState("");
                });
                stateProvider.assignState("Answering...");
              }
            } else {
              await _stopSpeaking();
              await _startListening();
              if (stateProvider.getState != "Listening...") {
                stateProvider.assignState("Listening...");
              }
            }
          },
          child: Icon(
            color: micColor,
            _isListening ? Icons.mic : Icons.mic_none,
          ),
        ),
      ),
    );
  }

  Future<void> _speaking(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
    _isSpeaking = true;
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        devtools.log('On status: $val');
      },
      onError: (val) => devtools.log('On error: $val'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        micColor = Colors.red;
      });

      devtools.log('Listening started');

      _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          });
        },
        localeId: "en_US",
      );
    } else {
      devtools.log('Speech not available');
    }
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
      micColor = Colors.blue;
    });
    await _speech.stop();
    devtools
        .log('Answering started'); // Speak the answer after stopping listening
  }
}
