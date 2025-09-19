
import 'package:bevert/core/services/settings_service.dart';
import 'package:flutter/material.dart';

class AccurateScreen extends StatefulWidget {
  const AccurateScreen({super.key});

  @override
  State<AccurateScreen> createState() => _AccurateScreenState();
}

class _AccurateScreenState extends State<AccurateScreen> {
  final SettingsService _settingsService = SettingsService();
  late double _currentValue = 3.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentValue();
  }

  Future<void> _loadCurrentValue() async {
    final value = await _settingsService.getSpeechPositiveThreshold();
    setState(() {
      _currentValue = _doubleToInt(value);
    });
  }

  double _intToDouble(double value) {
    return value / 5.0;
  }

  double _doubleToInt(double value) {
    return (value * 5).roundToDouble();
  }

  String _getDescriptionForValue(double value) {
    if (value == 1) {
      return '매우 민감: 주변 소음이나 작은 소리까지 녹음될 수 있지만, 중요한 순간을 놓치지 않을 수 있습니다.';
    } else if (value == 2) {
      return '민감: 작은 소리도 잘 포착하지만, 약간의 잡음이 섞일 수 있습니다.';
    } else if (value == 3) {
      return '균형: 대부분의 상황에서 음성을 잘 인식합니다.';
    } else if (value == 4) {
      return '정확: 명확한 음성만 녹음하려고 시도합니다.';
    } else {
      return '매우 정확: 명확한 음성만 녹음하지만, 조용한 발언은 놓칠 수 있습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("녹음 민감도 설정", style: theme.textTheme.bodyLarge,),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('현재 값', style: theme.textTheme.titleMedium),
                  Text(
                    _currentValue.toInt().toString(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _currentValue,
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: theme.primaryColor,
                inactiveColor: theme.disabledColor,
                thumbColor: theme.primaryColor,

                label: _currentValue.toInt().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentValue = value;
                  });
                },
                onChangeEnd: (double value) {
                  _settingsService.setSpeechPositiveThreshold(_intToDouble(value));
                },
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 설정',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDescriptionForValue(_currentValue),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
