# Changelog

## [Unreleased]
### Changed
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
### Added
- Added `fetchUser(String userId)` method to `UserService` to fetch a user by ID using the User model.
- Added `CelebrityUser` class extending `User` with fields: occupation, location, bio, website, followers, and posts.
- Updated `UserService.fetchUser` to support returning a dummy celebrity user with these fields when `isCelebrity` is true.
- Added new fields to `CelebrityUser` model: `socials`, `publicImageDescription`, `controversyMedia`, and `fashionStyle`.
- Populated these fields with realistic dummy data in `fetchUser` for celebrity users.
### Fixed
- Removed duplicate definition of `SupportedLanguage` and `supportedLanguages` from `auth_screen.dart` and now use the shared import from `l10n/supported_languages.dart`.
- Fixed null safety error by using `currentLocale?.languageCode` in the language dropdown.
- Fixed FeedScreen to always populate the posts list with dummy data in initState, preventing null/empty errors and ensuring post widgets display.
- Fixed FeedScreen to avoid calling setState directly in initState and only update posts/isLoading after a delay, preventing null errors in ListView.
- `UserService.fetchUser` now returns a dummy user for demonstration purposes instead of making a real API call.
- Fix: Modal now reliably closes when the blurred area/background is tapped (outside the modal content), using a full-screen GestureDetector with HitTestBehavior.opaque in showSlideUpDialog.

## [June 28, 2025]
- Initial changelog creation.

---
All future changes and fixes will be documented here with clear explanations and dates.
