# Sleep Cycle - Flutter Sleep Improvement Application

A beautiful and functional Flutter app designed to help users improve their sleep habits through personalized timers and motivational quotes.

## Features

### 🌟 4-Page Flow
1. **Welcome Page** - Displays random sleep health quotes and personalized buttons
2. **Sleep Timer Page** - Set bedtime reminders with custom tones
3. **Wake Timer Page** - Set wake-up alarms with music selection
4. **Completion Page** - Congratulatory screen with schedule summary

### 📱 Core Functionality
- **Random Quote Display**: 200+ carefully curated sleep health quotes
- **First-time vs Returning User**: Dynamic button text and flow
- **Time Picker Integration**: Easy-to-use time selection for sleep and wake schedules
- **Music/Tone Selection**: Choose from 8 built-in tones or custom files from device
- **Skip Options**: Users can skip sleep or wake reminders if desired
- **Data Persistence**: Settings saved using SharedPreferences
- **Notification Scheduling**: Automated reminders (ready for full implementation)
- **Beautiful UI**: Modern gradient design with smooth animations

### 🎵 Audio Features
- Built-in tone options:
  - Gentle Bells
  - Ocean Waves
  - Rain Sounds
  - Forest Ambience
  - Soft Piano
  - Wind Chimes
  - White Noise
  - Bird Songs
- Custom music selection from phone library
- Tone preview functionality

### 🎨 Design Highlights
- **Beautiful Background System**: Sophisticated layered backgrounds with:
  - Animated visual elements (stars, sun rays, particles)
  - Gradient overlays for perfect text readability
  - Theme-specific color schemes for each page
  - Graceful fallbacks when images are missing
- **Smooth Animations**: Scale, opacity, and rotation animations
- **Material Design**: Modern Flutter design principles
- **Responsive Layout**: Optimized for all screen sizes
- **Intuitive Navigation**: Seamless flow between pages
- **Professional Theming**: Carefully crafted color palettes

## File Structure

```
sleep/
├── lib/
│   ├── main.dart                    # App entry point and routing
│   ├── pages/
│   │   ├── welcome_page.dart        # Welcome screen with quotes
│   │   ├── sleep_timer_page.dart    # Sleep time configuration
│   │   ├── wake_timer_page.dart     # Wake time configuration
│   │   └── completion_page.dart     # Setup completion screen
│   ├── services/
│   │   ├── quote_service.dart       # Random quote management
│   │   ├── user_preferences.dart    # Data persistence
│   │   ├── audio_service.dart       # Music/tone handling
│   │   ├── notification_service.dart # Reminder scheduling
│   │   └── background_service.dart  # Background themes & animations
│   └── widgets/
│       └── background_demo.dart     # Background theme demonstration
├── assets/
│   ├── quotes/
│   │   └── sleep_quotes.txt        # 200+ sleep health quotes
│   ├── music/                      # Audio files directory
│   └── images/                     # Image assets directory
└── pubspec.yaml                    # Dependencies and configuration
```

## Dependencies

- `flutter`: Flutter SDK
- `cupertino_icons`: iOS-style icons
- `shared_preferences`: Data persistence

### Additional Dependencies (for full functionality)
To enable full audio and notification features, add these to pubspec.yaml:
- `flutter_local_notifications`: Push notifications
- `just_audio`: Audio playback
- `file_picker`: Custom file selection

## How to Run

1. Ensure Flutter is installed on your system
2. Navigate to the project directory:
   ```bash
   cd sleep
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Key Features Implementation

### User State Management
- Detects first-time vs returning users
- Persists sleep/wake times and preferences
- Remembers tone selections and reminder settings

### Quote System
- Loads 200+ quotes from text file
- Random selection on each app launch
- Refresh functionality for new inspiration
- Graceful fallback if file loading fails

### Timer Configuration
- Intuitive time picker interface
- Visual time display with large fonts
- Save/load previously set times
- Skip options for flexible usage

### Audio Selection
- Multiple built-in tone options
- Custom file picker integration (ready for implementation)
- Preview functionality for tone selection
- Tone preference persistence

### Notification System
- Scheduled notifications for sleep and wake times
- Customizable notification content
- Notification cancellation support
- Cross-platform compatibility

## User Experience Flow

1. **First Launch**: User sees "Let's fix your sleep cycle" button
2. **Sleep Setup**: Configure bedtime and notification tone
3. **Wake Setup**: Configure wake time and alarm tone
4. **Completion**: View schedule summary and confirmation
5. **Returning User**: See "Change settings" button and modify preferences

## Customization

### Adding More Quotes
Edit `assets/quotes/sleep_quotes.txt` and add new quotes (one per line).

### Adding Audio Files
Place audio files in `assets/music/` directory with these names:
- gentle_bells.mp3
- ocean_waves.mp3
- rain_sounds.mp3
- forest_ambience.mp3
- soft_piano.mp3
- wind_chimes.mp3
- white_noise.mp3
- bird_songs.mp3
- preview.mp3

### Background Customization
The app includes a sophisticated background system:

1. **Add Background Images**: Place PNG files in `assets/images/`:
   - `night_sky.png` - Welcome page (night sky theme)
   - `bedroom_night.png` - Sleep timer (cozy bedroom theme)
   - `morning_sunrise.png` - Wake timer (energizing sunrise theme)
   - `peaceful_dawn.png` - Completion page (serene dawn theme)
   - `subtle_pattern.png` - Optional overlay pattern

2. **Background Features**:
   - Animated visual elements unique to each page
   - Smart gradient overlays ensuring text readability
   - Graceful fallbacks when images are unavailable
   - Theme-specific color schemes and animations

3. **Visual Effects by Page**:
   - **Welcome**: 50 animated stars creating a night sky
   - **Sleep Timer**: Floating particles for calm atmosphere
   - **Wake Timer**: 8 animated sun rays for energizing feel
   - **Completion**: 30 colorful celebration particles

### Theme Customization
Modify colors and gradients in `lib/services/background_service.dart` and individual page files to match your brand.

## Technical Notes

- **State Management**: Uses StatefulWidget and SharedPreferences
- **Navigation**: Named routes for clean page transitions
- **Error Handling**: Graceful fallbacks for missing assets
- **Performance**: Lazy loading of quotes and efficient state updates
- **Cross-platform**: Compatible with iOS and Android

## Future Enhancements

- **Visual Enhancements**:
  - Dynamic backgrounds based on time of day
  - Seasonal background themes
  - User-customizable color schemes
  - 3D parallax effects with device motion

- **Core Features**:
  - Sleep tracking integration
  - Sleep quality analytics
  - Smart wake-up based on sleep cycles
  - Integration with health apps
  - Social features for sleep challenges
  - Advanced notification scheduling with time zones

- **Background System**:
  - Video backgrounds support
  - Interactive particle systems
  - Weather-based dynamic backgrounds
  - User photo integration

---

*Built with Flutter for optimal cross-platform performance and beautiful user experience.*