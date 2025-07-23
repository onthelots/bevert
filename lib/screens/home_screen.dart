import 'dart:async';
import 'package:bevert/screens/summary_screen.dart';
import 'package:bevert/services/summary_service.dart';
import 'package:bevert/services/translation_service.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SpeechToText _speechToText;
  bool _speechEnabled = false;
  String _lastWords = '';
  String _currentWords = '';
  String _translatedText = ''; // Add this state variable

  final List<String> _transcriptSegments = [];
  late SummaryService _summaryService;
  late TranslationService _translationService; // Add this service

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _summaryService = SummaryService();
    _translationService = TranslationService();

    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: (status) async {
      print('Speech status: $status');

      if (status == 'notListening') {
        // STT가 완전히 종료된 시점
        if (_transcriptSegments.isNotEmpty) {
          final fullText = _transcriptSegments.join(' ');

          // 한 번만 번역 호출
          final translated = await _translationService.translate(fullText);
          setState(() {
            _translatedText = translated;
          });
        }
      }
    });
    setState(() {});
  }

  Future<void> _startListening() async {
    _transcriptSegments.clear();
    _translatedText = '';
    _currentWords = '';

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _currentWords = result.recognizedWords;
        });

        if (result.finalResult) {
          _transcriptSegments.add(result.recognizedWords);
          _currentWords = '';
          // 번역 호출하지 않음! onStatus에서 처리
        }
      },
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'ko_KR',
      onSoundLevelChange: null,
    );

    setState(() {});
  }
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _speechToText.isListening;
    final displayTranscript = [..._transcriptSegments, _currentWords].join(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('BeVERT'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    displayTranscript.isEmpty ? 'Press the button to start listening...' : displayTranscript,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _translatedText.isEmpty ? 'Translation will appear here...' : _translatedText,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _speechEnabled ? (isListening ? _stopListening : _startListening) : null,
            label: Text(isListening ? 'Stop Listening' : 'Start Listening'),
            icon: Icon(isListening ? Icons.stop : Icons.mic),
            backgroundColor: isListening ? Colors.redAccent : Colors.tealAccent,
          ),
          const SizedBox(height: 10),
          if (!isListening && displayTranscript.isNotEmpty) // Show summarize button when not listening and transcript exists
            FloatingActionButton.extended(
              onPressed: () async {
                final fullTranscript = _transcriptSegments.join(' ');
                if (fullTranscript.trim().isEmpty) return;

                _showLoadingDialog();

                final summary = await _summaryService.summarize(fullTranscript);

                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      fullTranscript: fullTranscript,
                      summary: summary,
                    ),
                  ),
                );
              },
              label: const Text('Summarize Meeting'),
              icon: const Icon(Icons.summarize),
              backgroundColor: Colors.purpleAccent,
            ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("회의록을 요약하는 중..."),
              ],
            ),
          ),
        );
      },
    );
  }
}