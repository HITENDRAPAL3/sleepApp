import 'package:flutter/material.dart';
import '../services/white_noise_service.dart';
import '../widgets/background_container.dart';

class WhiteNoisePage extends StatefulWidget {
  const WhiteNoisePage({super.key});

  @override
  State<WhiteNoisePage> createState() => _WhiteNoisePageState();
}

class _WhiteNoisePageState extends State<WhiteNoisePage> with TickerProviderStateMixin {
  List<WhiteNoiseSound> _sounds = [];
  String? _selectedSoundId;
  String? _customAudioPath;
  Duration _selectedDuration = const Duration(minutes: 30);
  bool _isCustomDuration = false;
  int _customHours = 0;
  int _customMinutes = 30;
  bool _isPlaying = false;
  Duration _remainingTime = Duration.zero;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSounds();
    _setupWhiteNoiseCallbacks();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _setupWhiteNoiseCallbacks() {
    WhiteNoiseService.onPlayingStateChanged = (isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    };

    WhiteNoiseService.onTimeRemaining = (remaining) {
      if (mounted) {
        setState(() {
          _remainingTime = remaining;
        });
      }
    };
  }

  Future<void> _loadSounds() async {
    final sounds = await WhiteNoiseService.getWhiteNoiseSounds();
    if (mounted) {
      setState(() {
        _sounds = sounds;
        _selectedSoundId = sounds.isNotEmpty ? sounds.first.id : null;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('White Noise'),
        backgroundColor: const Color(0xFF2D3748),
        actions: [
          if (_isPlaying)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopWhiteNoise,
            ),
        ],
      ),
      body: NightBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimerDisplay(),
                  const SizedBox(height: 24),
                  _buildSoundSelection(),
                  const SizedBox(height: 24),
                  _buildDurationSelection(),
                  const SizedBox(height: 24),
                  _buildCustomAudioSection(),
                  const SizedBox(height: 32),
                  _buildPlayControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: _isPlaying
            ? Border.all(color: const Color(0xFF4A90E2), width: 2)
            : null,
      ),
      child: Column(
        children: [
          Text(
            _isPlaying ? 'Playing' : 'Ready',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _isPlaying ? const Color(0xFF4A90E2) : Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _isPlaying ? _pulseAnimation :
            const AlwaysStoppedAnimation(1.0),
            child: Text(
              WhiteNoiseService.formatDuration(_remainingTime),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (_isPlaying) ...[
            const SizedBox(height: 8),
            Text(
              _getSoundName(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoundSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Sound',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            // Ocean Waves tile
            _buildMainSoundTile(
              soundId: 'ocean_waves',
              title: 'Ocean Waves',
              description: 'Relaxing ocean sounds',
              icon: Icons.waves,
              color: const Color(0xFF4A90E2),
            ),

            // Space Ambience tile
            _buildMainSoundTile(
              soundId: 'space_ambience',
              title: 'Space Ambience',
              description: 'Deep space atmosphere',
              icon: Icons.nightlight_round,
              color: const Color(0xFF9C27B0),
            ),

            // Other Noises tile
            _buildOtherNoisesTile(),

            // Custom Audio tile
            _buildCustomAudioTile(),
          ],
        ),
      ],
    );
  }

  Widget _buildMainSoundTile({
    required String soundId,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedSoundId == soundId && _customAudioPath == null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSoundId = soundId;
          _customAudioPath = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.white30, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? color : color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherNoisesTile() {
    // Check if any "other" sound is selected
    final otherSounds = _sounds.where((s) =>
    s.id != 'ocean_waves' && s.id != 'space_ambience').toList();
    final isOtherSelected = otherSounds.any((s) => s.id == _selectedSoundId);

    return GestureDetector(
      onTap: _showOtherNoisesDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
          border: isOtherSelected
              ? Border.all(color: const Color(0xFF4CAF50), width: 2)
              : Border.all(color: Colors.white30, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.library_music,
                size: 28,
                color: isOtherSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4CAF50).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                'Other Noises',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isOtherSelected ? Colors.white : Colors.white70,
                  fontWeight: isOtherSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                isOtherSelected ? _getSelectedOtherSoundName() : 'More sound options',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAudioTile() {
    final isSelected = _customAudioPath != null;

    return GestureDetector(
      onTap: _pickCustomAudio,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF6B35), width: 2)
              : Border.all(color: Colors.white30, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                isSelected ? Icons.audio_file : Icons.upload_file,
                size: 28,
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFFFF6B35).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                'Custom Audio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                isSelected ? 'File selected' : 'Upload your audio',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherNoisesDialog() {
    final otherSounds = _sounds.where((s) =>
    s.id != 'ocean_waves' && s.id != 'space_ambience').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2D3748),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Choose Other Noise',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: otherSounds.length,
                itemBuilder: (context, index) {
                  final sound = otherSounds[index];
                  final isSelected = _selectedSoundId == sound.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A202C),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSoundIcon(sound.category),
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      title: Text(
                        sound.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        sound.description,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                          : const Icon(Icons.radio_button_unchecked, color: Colors.white30),
                      onTap: () {
                        setState(() {
                          _selectedSoundId = sound.id;
                          _customAudioPath = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getSelectedOtherSoundName() {
    final sound = _sounds.firstWhere(
          (s) => s.id == _selectedSoundId,
      orElse: () => _sounds.first,
    );
    return sound.name;
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Duration tiles in grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: WhiteNoiseService.getPresetDurations().length + 1, // +1 for custom duration tile
          itemBuilder: (context, index) {
            final presetDurations = WhiteNoiseService.getPresetDurations();

            if (index < presetDurations.length) {
              // Preset duration tile
              final duration = presetDurations[index];
              final isSelected = !_isCustomDuration && _selectedDuration == duration;

              return _buildDurationTile(
                title: WhiteNoiseService.formatDuration(duration),
                subtitle: _getDurationSubtitle(duration),
                icon: _getDurationIcon(duration),
                color: const Color(0xFF4A90E2),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedDuration = duration;
                    _isCustomDuration = false;
                  });
                },
              );
            } else {
              // Custom duration tile
              return _buildCustomDurationTile();
            }
          },
        ),

        // No longer showing custom duration inputs below - using popup instead
      ],
    );
  }

  Widget _buildDurationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.white30, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : color.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDurationTile() {
    final isSelected = _isCustomDuration;

    return GestureDetector(
      onTap: () {
        _showCustomDurationPicker();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF6B35), width: 2)
              : Border.all(color: Colors.white30, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: isSelected
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFFFF6B35).withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Custom',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              isSelected
                  ? WhiteNoiseService.formatDuration(_selectedDuration)
                  : 'Set time',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDurationPicker() {
    int tempHours = _customHours;
    int tempMinutes = _customMinutes;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Color(0xFF2D3748),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Set Custom Duration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),

            // Time picker
            Expanded(
              child: Row(
                children: [
                  // Hours picker
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hours',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              tempHours = index;
                            },
                            controller: FixedExtentScrollController(
                              initialItem: _customHours,
                            ),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 25, // 0-24 hours
                              builder: (context, index) {
                                final isSelected = index == tempHours;
                                return Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF6B35).withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFF6B35) : Colors.white70,
                                      fontSize: 20,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Separator
                  Container(
                    width: 2,
                    height: 100,
                    color: Colors.white30,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),

                  // Minutes picker
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Minutes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              tempMinutes = index;
                            },
                            controller: FixedExtentScrollController(
                              initialItem: _customMinutes,
                            ),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60, // 0-59 minutes
                              builder: (context, index) {
                                final isSelected = index == tempMinutes;
                                return Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF6B35).withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFF6B35) : Colors.white70,
                                      fontSize: 20,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _customHours = tempHours;
                          _customMinutes = tempMinutes;
                          _selectedDuration = Duration(hours: _customHours, minutes: _customMinutes);
                          _isCustomDuration = true;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Set Duration',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDurationSubtitle(Duration duration) {
    if (duration.inMinutes <= 30) {
      return 'Quick';
    } else if (duration.inHours <= 1) {
      return 'Short';
    } else if (duration.inHours <= 4) {
      return 'Medium';
    } else {
      return 'Long';
    }
  }

  IconData _getDurationIcon(Duration duration) {
    if (duration.inMinutes <= 30) {
      return Icons.timer;
    } else if (duration.inHours <= 1) {
      return Icons.access_time;
    } else if (duration.inHours <= 4) {
      return Icons.schedule;
    } else {
      return Icons.bedtime;
    }
  }

  Widget _buildCustomAudioSection() {
    // This section is now integrated into the main tiles, so we can remove it
    // or keep it for additional custom audio management if needed
    return const SizedBox.shrink();
  }

  Widget _buildPlayControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isPlaying ? _stopWhiteNoise : _playWhiteNoise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying
                      ? Colors.red
                      : const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  _isPlaying ? 'Stop' : 'Play',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_isPlaying) ...[
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: WhiteNoiseService.pauseResumeWhiteNoise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(
                  WhiteNoiseService.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  IconData _getSoundIcon(String category) {
    switch (category) {
      case 'nature':
        return Icons.nature;
      case 'ambient':
        return Icons.waves;
      case 'static':
        return Icons.radio;
      default:
        return Icons.music_note;
    }
  }

  String _getSoundName() {
    if (_customAudioPath != null) {
      return 'Custom Audio';
    }

    final sound = _sounds.firstWhere(
          (s) => s.id == _selectedSoundId,
      orElse: () => _sounds.isNotEmpty ? _sounds.first :
      const WhiteNoiseSound(
        id: '', name: 'Unknown', filename: '',
        description: '', category: '',
      ),
    );
    return sound.name;
  }

  Future<void> _pickCustomAudio() async {
    final path = await WhiteNoiseService.pickCustomAudio();
    if (path != null) {
      setState(() {
        _customAudioPath = path;
        _selectedSoundId = null;
      });
    }
  }

  Future<void> _playWhiteNoise() async {
    if ((_selectedSoundId == null && _customAudioPath == null) ||
        _selectedDuration.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sound and duration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await WhiteNoiseService.playWhiteNoise(
      soundId: _selectedSoundId ?? 'custom',
      duration: _selectedDuration,
      customPath: _customAudioPath,
    );
  }

  Future<void> _stopWhiteNoise() async {
    await WhiteNoiseService.stopWhiteNoise();
  }
}