import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucida/providers/state_provider.dart';
import 'package:lucida/providers/theme_provider.dart';
import 'package:lucida/themes.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

//log functions are used instead of using print.
import 'dart:developer' as devtools show log;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                StateProvider()), // first provider for changing states like listening, answering, and etc.
        ChangeNotifierProvider(
            create: (context) => ThemeProvider(
                lightTheme)), //second provider for switchind between dark and light themes.
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
  late stt.SpeechToText _speech; //from speech_to_text package.
  late FlutterTts _flutterTts; //from flutter_tts package.
  String _text = '';
  bool _isListening = false; //At Initial state, mic is turn off.
  Color micColor = Colors.blue;
  double _confidence =
      1.0; // Confidence rate is calculating with speech_to_text.

  //Ready Answers which will play answering states.
  final String _readyAnswer1 = 'My name is Luci. Nice to meet you';
  final String readyAnswer2 = 'I am fine. How about you?';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeechAndTts();
  }

  Future<void> _initializeSpeechAndTts() async {
    await _speech.initialize();
    await _flutterTts
        .setLanguage("en-US"); //Language is choose as American English.
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
                //for changing themes.
                value: themeProvider.getThemeData() ==
                    darkTheme, //provider states check and assign operations.
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
            //States are changed with state provider.
            child: Center(child: Text(stateProvider.getState)),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //Avatar Glow is used for microphone animation.
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () async {
            if (_isListening) {
              await _stopListening();
              await _startSpeaking(_readyAnswer1);
              //State changing
              if (stateProvider.getState != "Answering...") {
                stateProvider.assignState("Answering...");
                //If answering is completed, answering text will vanished.
                _flutterTts.setCompletionHandler(() {
                  stateProvider.assignState("");
                });
              }
            } else {
              await _stopSpeaking();
              await _startListening();
              //State changing
              if (stateProvider.getState != "Listening...") {
                stateProvider.assignState("Listening...");
              }
            }
          },
          child: Icon(
            //Microphone color state
            color: micColor,
            _isListening ? Icons.mic : Icons.mic_none,
          ),
        ),
      ),
    );
  }

  //Read ready answer
  Future<void> _startSpeaking(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  //If press again microphone button before answering ready answer, speaking stopping and listening again.
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  //Say something microphone and write texts on main screen. State changes are checked.
  Future<void> _startListening() async {
    devtools.log('Listening started');
    _speech.listen(
      onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
          _isListening = true;
          micColor = Colors.red;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
        });
      },
      localeId: "en_US",
    );
  }

  //Microphone is turn off and after ready answer should be read.
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
