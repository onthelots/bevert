import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_bloc.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecordingControlBar extends StatelessWidget {
  final int recordDuration;
  final RecorderController controller;
  final VoidCallback onMicTap;
  final VoidCallback onTranslate;
  final VoidCallback onFinish;
  final List<String> translatedSegments;

  const RecordingControlBar({
    super.key,
    required this.recordDuration,
    required this.controller,
    required this.onMicTap,
    required this.onTranslate,
    required this.onFinish,
    required this.translatedSegments,
  });

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final status = context.watch<RecordingBloc>().state.status;

    final isRecording = status == RecordingStatus.recording;
    final isPaused = status == RecordingStatus.paused;
    final isInitializing = status == RecordingStatus.initializing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 마이크 버튼
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording && !isPaused
                  ? Colors.redAccent
                  : theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isRecording
                    ? (isPaused ? Icons.mic : Icons.pause)
                    : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
              onPressed: isInitializing ? null : onMicTap,
            ),
          ),

          const SizedBox(width: 16),

          if (isRecording && !isPaused) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(recordDuration),
                    style: theme.textTheme.titleMedium
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: AudioWaveforms(
                      recorderController: controller,
                      waveStyle: WaveStyle(
                        waveColor: theme.primaryColor,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                      size: Size(screenWidth - 64 - 16 - 40, 40),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onTranslate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('번역', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: translatedSegments.isEmpty ? null : onFinish,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      '종료 및 문서번역',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
