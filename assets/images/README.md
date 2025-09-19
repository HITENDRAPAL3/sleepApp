# Image Assets

This folder contains background images and other visual assets for the Sleep Cycle app.

## Required Background Images

The app is configured to use the following background images. Replace the placeholder files with actual PNG images:

### 1. night_sky.png
- **Usage**: Welcome page background
- **Theme**: Night sky with stars, moon, peaceful evening scene
- **Recommended dimensions**: 1080x1920 (portrait)
- **Style**: Dark, calming, inspiring

### 2. bedroom_night.png
- **Usage**: Sleep timer page background
- **Theme**: Cozy bedroom scene, soft lighting, night atmosphere
- **Recommended dimensions**: 1080x1920 (portrait)
- **Style**: Warm, comfortable, sleepy

### 3. morning_sunrise.png
- **Usage**: Wake timer page background
- **Theme**: Beautiful sunrise, morning landscape, energizing scene
- **Recommended dimensions**: 1080x1920 (portrait)
- **Style**: Bright, energizing, fresh

### 4. peaceful_dawn.png
- **Usage**: Completion page background
- **Theme**: Peaceful dawn, accomplishment, serenity
- **Recommended dimensions**: 1080x1920 (portrait)
- **Style**: Serene, accomplished, hopeful

### 5. subtle_pattern.png (Optional)
- **Usage**: Overlay pattern for enhanced visual depth
- **Theme**: Subtle geometric or organic pattern
- **Recommended dimensions**: 512x512 (tileable)
- **Style**: Very subtle, low opacity overlay

## Current Implementation

The app uses a sophisticated background system that:
- Falls back gracefully if image files are missing
- Applies gradient overlays for text readability
- Includes animated visual elements (stars, sun rays, etc.)
- Uses different themes for each page

## Background Features by Page

### Welcome Page
- **Visual Elements**: Animated star field (50 stars)
- **Colors**: Deep night gradient (dark blues/purples)
- **Feel**: Mysterious, inspiring, peaceful

### Sleep Timer Page
- **Visual Elements**: Floating gentle particles
- **Colors**: Soft evening gradient (grays/blues)
- **Feel**: Calming, bedtime-ready, relaxing

### Wake Timer Page
- **Visual Elements**: Animated sun rays (8 rays)
- **Colors**: Fresh morning gradient (greens)
- **Feel**: Energizing, fresh, motivating

### Completion Page
- **Visual Elements**: Celebration particles (30 colorful dots)
- **Colors**: Success gradient (blues/purples/greens)
- **Feel**: Accomplished, celebratory, satisfied

## Image Guidelines

- **File Format**: PNG with transparency support
- **Quality**: High resolution for crisp display
- **Colors**: Should complement the gradient overlays
- **Contrast**: Ensure text remains readable with overlay
- **Size**: Optimize for mobile (keep under 1MB per image)

## Adding Your Images

1. Replace placeholder files with your actual images
2. Maintain the same file names for automatic loading
3. Test on different screen sizes
4. Ensure images work well with the gradient overlays
