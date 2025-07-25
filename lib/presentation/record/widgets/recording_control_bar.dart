import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class RecordingControlBar extends StatelessWidget {
  final bool isPaused;
  final bool isRecording;
  final int recordDuration;
  final RecorderController controller;
  final VoidCallback onMicTap;
  final VoidCallback onTranslate;
  final VoidCallback onFinish;
  final List<String> translatedSegments;

  const RecordingControlBar({
    super.key,
    required this.isPaused,
    required this.isRecording,
    required this.recordDuration,
    required this.controller,
    required this.onMicTap,
    required this.onTranslate,
    required this.onFinish,
    required this.translatedSegments,
  });

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
          // 녹음/일시정지/재생 버튼 (둥근 원)
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
                )
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
              onPressed: onMicTap,
            ),
          ),

          const SizedBox(width: 16),

          // 녹음 중이고 일시정지 상태가 아닌 경우: 타이머 + waveform 보여주기
          if (isRecording && !isPaused) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(recordDuration),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: AudioWaveforms(
                      recorderController: controller,
                      waveStyle: const WaveStyle(
                        waveColor: Colors.blue,
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
            // 녹음 중이 아니거나 일시정지인 경우: 재생 버튼 + 번역/종료 버튼 가로 정렬

            // 남은 공간에 버튼 3개를 균등 분배시키기 위해 Flexible 사용
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 번역 버튼
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

                  // 종료 및 문서번역 버튼
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
