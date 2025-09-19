import 'package:flutter/material.dart';
import '../services/background_service.dart';

class BackgroundContainer extends StatefulWidget {
  final Widget child;
  final BackgroundType backgroundType;
  final bool useRandomBackground;

  const BackgroundContainer({
    super.key,
    required this.child,
    required this.backgroundType,
    this.useRandomBackground = true,
  });

  @override
  State<BackgroundContainer> createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  String? _backgroundPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.useRandomBackground) {
      _loadBackground();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadBackground() async {
    try {
      String backgroundPath;

      switch (widget.backgroundType) {
        case BackgroundType.welcome:
          backgroundPath = await BackgroundService.getWelcomeBackground();
          break;
        case BackgroundType.night:
          backgroundPath = await BackgroundService.getNightBackground();
          break;
        case BackgroundType.morning:
          backgroundPath = await BackgroundService.getMorningBackground();
          break;
        case BackgroundType.completion:
          backgroundPath = await BackgroundService.getCompletionBackground();
          break;
      }

      if (mounted) {
        setState(() {
          _backgroundPath = backgroundPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading background: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _buildFallbackGradient(),
      ),
      child: Container(
        decoration: !_isLoading && _backgroundPath != null
            ? _buildImageDecoration(_backgroundPath!)
            : null,
        child: widget.child,
      ),
    );
  }

  /// Build gradient decoration as fallback
  LinearGradient _buildFallbackGradient() {
    final colors = BackgroundService.getFallbackGradient(widget.backgroundType);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors.map((color) => Color(color)).toList(),
    );
  }

  /// Build image decoration with specific path
  BoxDecoration _buildImageDecoration(String backgroundPath) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(backgroundPath),
        fit: BoxFit.cover,
        onError: (error, stackTrace) {
          // If image fails to load, the gradient fallback will show
          debugPrint('Background image failed to load: $backgroundPath');
        },
      ),
    );
  }
}

/// Specialized background container for each page type
class WelcomeBackground extends StatelessWidget {
  final Widget child;

  const WelcomeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundType: BackgroundType.welcome,
      child: child,
    );
  }
}

class NightBackground extends StatelessWidget {
  final Widget child;

  const NightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundType: BackgroundType.night,
      child: child,
    );
  }
}

class MorningBackground extends StatelessWidget {
  final Widget child;

  const MorningBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundType: BackgroundType.morning,
      child: child,
    );
  }
}

class CompletionBackground extends StatelessWidget {
  final Widget child;

  const CompletionBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundType: BackgroundType.completion,
      child: child,
    );
  }
}
