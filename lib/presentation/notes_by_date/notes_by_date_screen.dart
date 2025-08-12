import 'dart:collection';

import 'package:bevert/core/di/locator.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:bevert/presentation/notes_by_date/widgets/year_month_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class NotesByDateScreen extends StatefulWidget {
  const NotesByDateScreen({super.key});

  @override
  State<NotesByDateScreen> createState() => _NotesByDateScreenState();
}

class _NotesByDateScreenState extends State<NotesByDateScreen> {
  late final FetchTranscriptsUseCase _fetchTranscriptsUseCase;
  LinkedHashMap<DateTime, List<TranscriptRecord>> _events = LinkedHashMap();

  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TranscriptRecord> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchTranscriptsUseCase = locator<FetchTranscriptsUseCase>();
    _selectedDay = _focusedDay;
    _loadTranscripts();
  }

  Future<void> _loadTranscripts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _fetchTranscriptsUseCase.call();
      final events = LinkedHashMap<DateTime, List<TranscriptRecord>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      );

      for (final record in records) {
        final date = DateTime.utc(record.createdAt.year, record.createdAt.month, record.createdAt.day);
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(record);
      }

      setState(() {
        _events = events;
        _selectedEvents = _getEventsForDay(_selectedDay!);
        _isLoading = false;
      });
    } catch (e) {
      // Handle error appropriately
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TranscriptRecord> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  void _showYearMonthPicker() {
    showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return YearMonthPicker(initialDate: _focusedDay);
      },
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _focusedDay = pickedDate;
          _selectedDay = pickedDate;
          _selectedEvents = _getEventsForDay(_selectedDay!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              '날짜별 노트',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              DateFormat('yyyy년 M월', 'ko_KR').format(_focusedDay),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showYearMonthPicker,
          ),
        ],
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<TranscriptRecord>(
                  locale: 'ko_KR',
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    titleTextStyle: const TextStyle(fontSize: 0),
                  ),
                  calendarStyle: CalendarStyle(
                    // Marker for events
                    markerDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    // Today's date style
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: theme.colorScheme.onSecondary),
                    // Selected date style
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Divider(
                  height: 20.0,
                  thickness: 10.0,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _selectedEvents.isEmpty
                      ? const Center(
                          child: Text('선택한 날짜에 작성된 노트가 없습니다.'),
                        )
                      : ListView.builder(
                          itemCount: _selectedEvents.length,
                          itemBuilder: (context, index) {
                            final record = _selectedEvents[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                title: Text(record.title),
                                subtitle: Text(
                                  DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt),
                                  style: theme.textTheme.bodySmall,
                                ),
                                onTap: () {
                                  context.push(AppRouter.summary.path, extra: (record, false));
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}