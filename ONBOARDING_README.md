# Rock Identifier Onboarding Screen

This document describes the new onboarding screen implementation that recreates the SwiftUI design in Flutter.

## Features

### 🎨 Visual Design
- **Header/Footer Decorations**: Subtle gradient overlays with auto-awesome icons
- **Progress Indicator**: Three-step progress with animated icons (bug, camera, sparkles)
- **Dark Theme**: Consistent with app's dark theme using green accent colors
- **Smooth Transitions**: Fade and slide animations between steps

### 📱 Three Onboarding Steps

#### Step 1: Welcome
- Welcome message and app description
- Animated testimonial with user avatar and 5-star rating
- Trust indicator: "Trusted by herpetologists worldwide"

#### Step 2: Photo Identification
- Photo-taking demonstration with Rock image
- Hand animation showing touch interaction
- Flash effect and identification result
- Trust indicator: "Millions of Rocks identified"

#### Step 3: AI Power
- Binary code animation scrolling horizontally
- AI icon overlay
- Trust indicator: "Trained on extensive Rock database"

### ✨ Animations
- **Testimonial**: Scale, rotation, and blur effects
- **Photo Animation**: Hand movement, flash, and identification sequence
- **AI Animation**: Scrolling binary code with different speeds
- **Progress**: Scale animations for active steps
- **Content**: Fade and slide transitions

## Customization

### Colors
- Primary accent: `AppTheme.sandstone`
- Background: `AppTheme.nearBlack`
- Text: `Colors.white` with alpha variations

### Images
- **Rock Image**: Uses `assets/images/Rock.jpg`
- **Header/Footer**: Currently uses gradient overlays with icons
- **Avatar**: Placeholder person icon (can be replaced with actual user images)

### Text Content
- All text content is easily customizable in the respective `_build*Step()` methods
- Trust indicators can be modified in `_getTrustText()` method

### Animation Timing
- Testimonial: 3.4 seconds per cycle
- Photo animation: 4 seconds per cycle
- AI animation: 10 seconds per cycle
- Step transitions: 500ms fade + 500ms delay

## Technical Implementation

### Animation Controllers
- `_testimonialController`: Handles testimonial animations
- `_photoAnimationController`: Manages photo-taking sequence
- `_aiAnimationController`: Controls AI/binary code animation

### State Management
- `_step`: Current onboarding step (0-2)
- `_animatedStep`: Animated progress indicator value
- `_onboardingOpacity`: Content fade animation

### Widget Structure
```
OnboardingScreen
├── Header/Footer Background
├── Progress Indicator
├── Content Area (Animated)
│   ├── Welcome Step
│   ├── Photo Step
│   └── AI Step
└── Bottom Section
    ├── Continue Button
    └── Trust Indicators
```

## Future Enhancements

1. **Custom Images**: Replace placeholder icons with actual header/footer images
2. **User Avatars**: Add real user profile pictures to testimonials
3. **Localization**: Support for multiple languages
4. **Accessibility**: Voice-over support and screen reader compatibility
5. **Analytics**: Track user progress through onboarding steps

## Usage

The onboarding screen is automatically shown when the app first launches. Users can navigate through the three steps using the "Continue" button, with smooth animations between each step.

```dart
OnboardingScreen(
  onFinish: () {
    // Navigate to main app
    Navigator.pushReplacement(context, MainScreen());
  },
)
```
