import 'dart:async';
import 'package:bevert/presentation/summary/summary_screen.dart';
import 'package:bevert/services/summary_service.dart';
import 'package:bevert/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late SpeechToText _speechToText;
  bool _isRecording = false;
  bool _isPaused = false;
  String _currentWords = '';
  final List<String> _translatedSegments = [];

  late SummaryService _summaryService;
  late TranslationService _translationService;

  Timer? _timer;
  int _recordDuration = 0;

  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _summaryService = SummaryService();
    _translationService = TranslationService();
    _recorderController = RecorderController();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize(
      onStatus: (status) async {
        if (status == 'notListening' && _isRecording && !_isPaused) {
          _stopTimer();
          setState(() {
            _isRecording = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Speech recognition error: $error');
      },
    );
  }

  void _onMicButtonPressed() {
    if (!_isRecording) {
      _startListening();
    } else if (_isRecording && !_isPaused) {
      _pauseListening();
    } else if (_isRecording && _isPaused) {
      _resumeListening();
    }
  }

  void _startListening() {
    _translatedSegments.clear();
    _currentWords = '';
    _recordDuration = 0;

    _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
      ),
      localeId: 'ko_KR',
    );

    _recorderController.record();
    _startTimer();
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
  }

  void _pauseListening() {
    _speechToText.stop();
    _recorderController.pause();
    _stopTimer();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeListening() {
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
      ),
      localeId: 'ko_KR',
    );
    _recorderController.record();
    _startTimer();
    setState(() {
      _isPaused = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.finalResult) {
      final translated = await _translationService.translate(result.recognizedWords);
      setState(() {
        _translatedSegments.add(translated);
        _currentWords = '';
      });
    } else {
      setState(() {
        _currentWords = result.recognizedWords;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _speechToText.stop();
    _timer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayTranscript = [..._translatedSegments, _currentWords].join(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('회의 녹음'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width, 50),
              recorderController: _recorderController,
              waveStyle: const WaveStyle(
                waveColor: Colors.blue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    displayTranscript.isEmpty
                        ? '녹음 버튼을 눌러 시작하세요...'
                        : displayTranscript,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(fontSize: 24.0),
            ),
            FloatingActionButton(
              onPressed: _onMicButtonPressed,
              child: Icon(
                !_isRecording
                    ? Icons.mic
                    : (_isPaused ? Icons.play_arrow : Icons.pause),
              ),
            ),
            TextButton(
              onPressed: () async {
                _pauseListening();
                final fullTranscript = displayTranscript;
                if (fullTranscript.trim().isEmpty) return;

                _showLoadingDialog();
                final summary = await _summaryService.summarize(fullTranscript);
                Navigator.of(context).pop();

                final newLog = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      fullTranscript: fullTranscript,
                      summary: summary,
                    ),
                  ),
                );

                if (newLog != null) {
                  Navigator.of(context).pop(newLog);
                }
              },
              child: const Text('종료'),
            ),
          ],
        ),
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