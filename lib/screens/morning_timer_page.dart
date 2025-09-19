import 'package:flutter/material.dart';
import '../models/audio_file.dart';
import '../models/sleep_timer.dart';
import '../services/audio_service.dart';
import '../services/preferences_service.dart';
import 'completion_page.dart';

class MorningTimerPage extends StatefulWidget {
  const MorningTimerPage({super.key});

  @override
  State<MorningTimerPage> createState() => _MorningTimerPageState();
}

class _MorningTimerPageState extends State<MorningTimerPage> with TickerProviderStateMixin {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  List<AudioFile> _audioFiles = [];
  String _selectedAudioId = '';
  String? _customAudioPath;
  bool _isLoading = true;
  bool _isPlayingPreview = false;
  String? _previewingAudioId;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadData() async {
    try {
      final audioFiles = await AudioService.getAvailableAudioFiles();
      final existingTimer = await PreferencesService.getMorningTimer();

      setState(() {
        _audioFiles = audioFiles;
        _selectedAudioId = audioFiles.isNotEmpty ? audioFiles.first.id : '';

        if (existingTimer != null) {
          _selectedTime = existingTimer.time;
          _selectedAudioId = existingTimer.selectedAudioId;
          _customAudioPath = existingTimer.customAudioPath;
        }

        _isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF2D3748),
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dialHandColor: const Color(0xFF4A90E2),
              dialTextColor: Colors.white,
              helpTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _playAudioPreview(String audioId) async {
    if (_isPlayingPreview && _previewingAudioId == audioId) {
      await AudioService.stopAudio();
      setState(() {
        _isPlayingPreview = false;
        _previewingAudioId = null;
      });
    } else {
      await AudioService.stopAudio();
      setState(() {
        _isPlayingPreview = true;
        _previewingAudioId = audioId;
      });

      await AudioService.playAudio(audioId);

      // Auto-stop preview after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_previewingAudioId == audioId) {
          AudioService.stopAudio();
          setState(() {
            _isPlayingPreview = false;
            _previewingAudioId = null;
          });
        }
      });
    }
  }

  Future<void> _pickCustomAudio() async {
    final audioPath = await AudioService.pickCustomAudio();
    if (audioPath != null) {
      setState(() {
        _customAudioPath = audioPath;
        _selectedAudioId = 'custom';
      });
    }
  }

  Future<void> _saveAndComplete() async {
    final timer = SleepTimer(
      time: _selectedTime,
      selectedAudioId: _selectedAudioId,
      customAudioPath: _customAudioPath,
    );

    await PreferencesService.saveMorningTimer(timer);
    await PreferencesService.setFirstTimeUserFlag(false);
    await PreferencesService.setSetupCompleted(true);

    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CompletionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _skipMorningTimer() {
    _completeSetup();
  }

  Future<void> _completeSetup() async {
    await PreferencesService.setFirstTimeUserFlag(false);
    await PreferencesService.setSetupCompleted(true);

    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CompletionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    AudioService.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Wake-up Timer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _skipMorningTimer,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90E2),
        ),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A202C),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: const Color(0xFFFFD700),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Set Your Wake-up Time',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose when you want to wake up and pick an energizing tone to start your day.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Picker Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3748),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Wake-up Time',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: _selectTime,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to change time',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Audio Selection Section
                            Text(
                              'Choose Your Wake-up Tone',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Built-in Audio Files
                            ...(_audioFiles.map((audio) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3748),
                                borderRadius: BorderRadius.circular(12),
                                border: _selectedAudioId == audio.id
                                    ? Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: ListTile(
                                title: Text(
                                  audio.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  audio.description,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    audio.type == 'nature'
                                        ? Icons.nature
                                        : audio.type == 'music'
                                        ? Icons.music_note
                                        : Icons.notifications,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isPlayingPreview && _previewingAudioId == audio.id
                                            ? Icons.stop
                                            : Icons.play_arrow,
                                        color: const Color(0xFFFFD700),
                                      ),
                                      onPressed: () => _playAudioPreview(audio.id),
                                    ),
                                    Radio<String>(
                                      value: audio.id,
                                      groupValue: _selectedAudioId,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAudioId = value!;
                                          _customAudioPath = null;
                                        });
                                      },
                                      activeColor: const Color(0xFFFFD700),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedAudioId = audio.id;
                                    _customAudioPath = null;
                                  });
                                },
                              ),
                            ))),

                            // Custom Audio Option
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3748),
                                borderRadius: BorderRadius.circular(12),
                                border: _selectedAudioId == 'custom'
                                    ? Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: ListTile(
                                title: Text(
                                  _customAudioPath != null
                                      ? 'Custom Audio Selected'
                                      : 'Choose Custom Audio',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  _customAudioPath != null
                                      ? 'Using your selected audio file'
                                      : 'Pick from your phone\'s library',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.folder_open,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                trailing: Radio<String>(
                                  value: 'custom',
                                  groupValue: _selectedAudioId,
                                  onChanged: (value) async {
                                    await _pickCustomAudio();
                                  },
                                  activeColor: const Color(0xFFFFD700),
                                ),
                                onTap: _pickCustomAudio,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Complete Setup Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAndComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle),
                        ],
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

