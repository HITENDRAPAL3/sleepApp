import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';

class SleepTimerPage extends StatefulWidget {
  const SleepTimerPage({super.key});

  @override
  State<SleepTimerPage> createState() => _SleepTimerPageState();
}

class _SleepTimerPageState extends State<SleepTimerPage> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 22, minute: 0);
  String _selectedTone = 'Gentle Bells';
  List<String> _availableTones = [];
  bool _skipThisProcess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tones = await AudioService.getAvailableTones();
    final savedTime = await UserPreferences.getSleepTime();
    final savedTone = await UserPreferences.getSleepTone();

    setState(() {
      _availableTones = tones;
      if (savedTone != null) {
        _selectedTone = savedTone;
      }
      if (savedTime != null) {
        final parts = savedTime.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectTone() async {
    await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Sleep Tone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._availableTones.map((tone) => ListTile(
                title: Text(tone),
                leading: Icon(
                  _selectedTone == tone ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: const Color(0xFF667EEA),
                ),
                onTap: () {
                  setState(() {
                    _selectedTone = tone;
                  });
                  AudioService.playPreview(tone);
                  Navigator.pop(context);
                },
              )),
              const Divider(),
              ListTile(
                title: const Text('Custom from Phone'),
                leading: const Icon(Icons.music_note, color: Color(0xFF667EEA)),
                onTap: () async {
                  final customTone = await AudioService.pickCustomTone();
                  if (customTone != null) {
                    setState(() {
                      _selectedTone = 'Custom: $customTone';
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAndContinue() async {
    if (!_skipThisProcess) {
      await UserPreferences.setSleepTime('${_selectedTime.hour}:${_selectedTime.minute}');
      await UserPreferences.setSleepTone(_selectedTone);
      await UserPreferences.setSleepReminderEnabled(true);

      // Schedule notification for sleep time
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // If the time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await NotificationService.scheduleNotification(
        id: 1,
        title: 'Sleep Time! 🌙',
        body: 'Time to prepare for a restful night\'s sleep.',
        scheduledTime: scheduledTime,
      );
    } else {
      await UserPreferences.setSleepReminderEnabled(false);
    }

    Navigator.pushNamed(context, '/wake-timer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Timer'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BackgroundService.buildPatternBackground(
              theme: 'sleep',
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Your Sleep Time',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose when you want to go to bed and get reminded.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Time Selection Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _selectTime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                              ),
                              child: const Text('Change Time'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tone Selection Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Notification Tone',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _selectTone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                              ),
                              child: const Text('Choose Tone'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Skip Option
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _skipThisProcess,
                              onChanged: (value) {
                                setState(() {
                                  _skipThisProcess = value ?? false;
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                            const Expanded(
                              child: Text(
                                'Skip sleep reminders',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Next: Wake Up Timer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
