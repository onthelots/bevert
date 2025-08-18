import 'package:bevert/presentation/record/bloc/recording/recording_bloc.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:bevert/presentation/record/widgets/recording_ripple_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecordingControlBar extends StatelessWidget {
  final VoidCallback onMicTap;
  final VoidCallback onFinish;
  final List<String> segments;

  const RecordingControlBar({
    super.key,
    required this.onMicTap,
    required this.onFinish,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<RecordingBloc>().state;
    final status = state.status;

    final isRecording = status == RecordingStatus.recording;
    final isPaused = status == RecordingStatus.paused;
    final isInitializing = status == RecordingStatus.initializing;

    final amplitude = state.amplitude.clamp(0.0, 1.0);
    final double buttonSize = 64; // 아이콘 크기 고정
    final double horizontalPadding = 16;
    final double sideButtonWidth = 40;

    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 좌측 임시 아이콘 + 우측 버튼
          if (!isRecording || isPaused)
            Row(
              children: [
                SizedBox(
                  width: sideButtonWidth,
                  height: sideButtonWidth,
                  child: Icon(Icons.g_translate, color: theme.hintColor,),
                ),
                const Spacer(),
                TextButton(
                  onPressed: segments.isEmpty ? null : onFinish,
                  style: TextButton.styleFrom(
                    foregroundColor: segments.isEmpty
                        ? theme.disabledColor
                        : theme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  child: Text(
                    '노트 종료',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: segments.isEmpty
                          ? theme.dividerColor
                          : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            )
          else
          // 녹음 중일 때 오른쪽 X 버튼만
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onMicTap,
                icon: const Icon(Icons.close),
              ),
            ),

          // 중앙 녹음 버튼 + 발화 파동
          Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isRecording && !isPaused && amplitude > 0.01)
                  MultiRippleAnimation(
                    size: buttonSize,
                    amplitude: amplitude,
                    color: Colors.redAccent,
                    rippleCount: 3,
                  ),
                Container(
                  width: buttonSize,
                  height: buttonSize,
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
                    icon: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: isInitializing ? null : onMicTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
