# Changelog

## [Unreleased]
### Added
- Created `AudioCard` widget for audio post playback with real audio using just_audio, animated waveform, and speed control.
- Added a moving orange indicator to the waveform progress bar in `AudioCard` that tracks audio progress in real time.
- Implemented dummy data for audio posts with working audio URLs and thumbnails.
- Integrated play/pause, speed toggle, and progress bar with time display in `AudioCard`.
- Added bottom action buttons (like, comment, share, send) to `AudioCard`.
- Implemented TikTok/Reels-like live stream experience for `LiveStreamCard` and live stream detail page.
- Created `LiveStreamVideoManager` service to manage video controllers globally, ensuring only one video plays at a time and controllers persist across navigation.
- Refactored `LiveStreamCard` to use the video manager, autoplay only when visible, and wrap the video in a `Hero` for smooth transition.
- Added `LiveStreamDetailPage` that receives the same video controller and animates the video to fullscreen, unmuting and continuing playback seamlessly.
- Tapping a live stream card now triggers a smooth Hero transition to the detail page, with uninterrupted video playback and unmuting.
- Onboarding flow: Created and styled onboarding screens (welcome, OTP, account type, country/state/city selection), with adaptive colors and navigation logic using _currentIndex.
- Authentication: Implemented login/register forms with robust validation, profile image selection, and error handling. Improved UI for profile photo selection.
- Verification: Built a verification screen with live camera preview, front/back ID photo capture, retake logic, and enforced both images before submission. Moved ID photo previews below the retake button and improved UI logic.
- Celebrity profile creation: Built a multi-tab flow (celebrate you, add family, add wealth, add education) with navigation and a Lottie animation background for the first tab. Added a timeout to auto-advance from the first to the second tab.
- Progress indicator: Updated to show four dots for four onboarding/profile creation steps.
- All navigation and validation logic is performed after form state is saved, preventing false negatives on required fields.
- Added search bar to "Add Family" tab in celebrity profile creation, displaying accounts from dummy data in feed_service.dart. If no user is found, an invite button is shown.

### Changed
- Enhanced `_buildWaveformProgress` in `AudioCard` to overlay a moving orange indicator that follows audio playback progress.
- Improved layout and overflow handling in `AudioCard` for better responsiveness.
- Refactored `AuthScreen` to use `AppState` ChangeNotifier from Provider for theme and locale changes, instead of using Provider for callbacks.
- Removed all Provider lookups for `VoidCallback` and `ValueChanged<Locale>` in `auth_screen.dart`.
- Now uses `appState.toggleTheme()` for theme changes.
- Removed localization and static string management from `auth_screen.dart`.
- Cleaned up unused imports and parameters related to localization.
- Created this CHANGELOG.md file to document all changes made by GitHub Copilot.
- Investigated issue where the custom splash screen is not visible and the Flutter logo still appears at launch.
- Confirmed that no changes to Gradle files are required for updating the launch screen in Flutter. The splash screen is controlled by XML resources and the manifest theme.
- Recommended running `flutter clean` and rebuilding the app to clear cache issues. Also advised checking for packages like `flutter_native_splash` that may overwrite splash resources.
- Added multilingual support (English and Spanish) using custom localization files and `flutter_localizations`.
- Implemented light/dark mode toggle with Binance color scheme. Default theme follows system setting.
- Added toggle buttons for theme and language in the app bar.
- To toggle theme: tap the brightness icon in the app bar. To toggle language: tap the language icon in the app bar.
- Updated `pubspec.yaml` to include localization dependencies.
- Removed all custom localization logic from `app_localizations.dart` and marked it as obsolete. All localization is now handled by ARB files and Flutter's intl tools. You can safely delete `app_localizations.dart` and `app_localizations.json`.
- Refactored `main.dart` and `auth_screen.dart` for theme and localization support.
- Switched to ARB-based localization for language support. Added ARB files for English, Spanish, French, German, Italian, Swahili, and Arabic.
- Added a language dropdown in the navbar for selecting supported languages.
- Updated registration form in `AuthScreen` to only include fields required by the backend (`fullName`, `email`, `username`, `password`, `role`, `confirm password`).
- Added validation for all registration fields, similar to the sign-in screen.
- Removed unused registration fields from the form and state.
- Updated `pubspec.yaml` to enable Flutter's code generation for ARB localization.
- Refactored locale change logic to use a callback and support all ARB locales.
- Documented all previous and new changes for better tracking.
- Connected login and registration forms in `AuthScreen` to backend APIs using `UserService` after validation.
- Added a top error banner (styled as in the design) to the login, signup, and onboarding forms for consistent error display.
- Improved `ProfilePage` UI: removed unnecessary space above the posts/followers row and made the TabBar responsive for both light and dark mode, matching the provided design. TabBar now uses an underline indicator and adapts its colors and text styles based on the theme.
- Flicks tab now reliably displays dummy data when switching tabs or on first open.
- All dummy flicks video links in `SearchService.searchFlicks` updated to use only working, reliable MP4 URLs (sample-videos.com, w3schools.com, learningcontainer.com).

### Fixed
- Removed duplicate definition of `SupportedLanguage` and `supportedLanguages` from `auth_screen.dart` and now use the shared import from `l10n/supported_languages.dart`.
- Fixed null safety error by using `currentLocale?.languageCode` in the language dropdown.
- Fixed FeedScreen to always populate the posts list with dummy data in initState, preventing null/empty errors and ensuring post widgets display.
- Fixed FeedScreen to avoid calling setState directly in initState and only update posts/isLoading after a delay, preventing null errors in ListView.
- `UserService.fetchUser` now returns a dummy user for demonstration purposes instead of making a real API call.
- Fix: Modal now reliably closes when the blurred area/background is tapped (outside the modal content), using a full-screen GestureDetector with HitTestBehavior.opaque in showSlideUpDialog.
- Ensured the waveform progress bar and indicator update smoothly as audio plays, with no overflow or layout issues.
- Fixed onboarding and registration validation to only trigger after form state is saved.
- Fixed ID verification UI to move previews below retake button and enforce both images before submission.
- Fixed search in "Add Family" tab to update results live and show invite option if user not found.

## [June 28, 2025]
- Initial changelog creation.

## [July 4, 2025]
### Changed
- Implemented `FlickControllerManager` to ensure only one video controller is active at a time in the flicks screen, preventing memory leaks and controller overlap.
- Updated `FlickScreen` to use `PageView.builder(keepPage: false)` so only the current page is kept alive, reducing memory usage and ensuring TikTok-like behavior.
- Refactored `_FlickPlayer` to always reset the progress bar to 0 while loading a new video, and only update it when the controller is initialized, ensuring no progress bar carry-over between videos.
- Improved user experience: each video always starts from the beginning, and the progress bar reflects the new video's state immediately, just like TikTok.

## [July 8, 2025]
### Added
- Onboarding flow: Created and styled onboarding screens (welcome, OTP, account type, country/state/city selection), with adaptive colors and navigation logic using _currentIndex.
- Authentication: Implemented login/register forms with robust validation, profile image selection, and error handling. Improved UI for profile photo selection.
- Verification: Built a verification screen with live camera preview, front/back ID photo capture, retake logic, and enforced both images before submission. Moved ID photo previews below the retake button and improved UI logic.
- Celebrity profile creation: Built a multi-tab flow (celebrate you, add family, add wealth, add education) with navigation and a Lottie animation background for the first tab. Added a timeout to auto-advance from the first to the second tab.
- Progress indicator: Updated to show four dots for four onboarding/profile creation steps.
- All navigation and validation logic is performed after form state is saved, preventing false negatives on required fields.
- Added search bar to "Add Family" tab in celebrity profile creation, displaying accounts from dummy data in feed_service.dart. If no user is found, an invite button is shown.

### Changed
- Improved UI for onboarding, authentication, and verification flows to match app requirements for both light/dark mode and user/celebrity flows.
- Enhanced error handling and field validation throughout onboarding and authentication.
- Improved navigation logic and user experience in all onboarding/profile creation steps.
- Updated profile image and ID photo handling for better UX and error prevention.

### Fixed
- Fixed onboarding and registration validation to only trigger after form state is saved.
- Fixed ID verification UI to move previews below retake button and enforce both images before submission.
- Fixed search in "Add Family" tab to update results live and show invite option if user not found.

---
All future changes and fixes will be documented here with clear explanations and dates.
