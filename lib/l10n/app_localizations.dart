import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @drawerHeader.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get drawerHeader;

  /// No description provided for @item1.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get item1;

  /// No description provided for @item2.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get item2;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @thankYouForSigningUp.
  ///
  /// In en, this message translates to:
  /// **'Thank you for signing up!'**
  String get thankYouForSigningUp;

  /// No description provided for @thankYouForRegistering.
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering. Please complete your profile to continue.'**
  String get thankYouForRegistering;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A code has been sent to {email}'**
  String codeSentTo(Object email);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @didNotReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email?'**
  String get didNotReceiveEmail;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Choose Account Type'**
  String get chooseAccountType;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @memberDescription.
  ///
  /// In en, this message translates to:
  /// **'Access community features and connect with others.'**
  String get memberDescription;

  /// No description provided for @celebrityStatus.
  ///
  /// In en, this message translates to:
  /// **'Celebrity Status'**
  String get celebrityStatus;

  /// No description provided for @celebrityDescription.
  ///
  /// In en, this message translates to:
  /// **'Get verified and unlock exclusive features.'**
  String get celebrityDescription;

  /// No description provided for @continueAsMember.
  ///
  /// In en, this message translates to:
  /// **'Continue as Member'**
  String get continueAsMember;

  /// No description provided for @continueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as'**
  String get continueAs;

  /// No description provided for @celebrity.
  ///
  /// In en, this message translates to:
  /// **'Celebrity'**
  String get celebrity;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Celebrating'**
  String get appTitle;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @toggleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Toggle Language'**
  String get toggleLanguage;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name required'**
  String get fullNameRequired;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordRequired;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Role required'**
  String get roleRequired;

  /// No description provided for @signUpForAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign Up for an Account'**
  String get signUpForAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @celebrating.
  ///
  /// In en, this message translates to:
  /// **'Celebrating'**
  String get celebrating;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name required'**
  String get firstNameRequired;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name required'**
  String get lastNameRequired;

  /// No description provided for @selectSex.
  ///
  /// In en, this message translates to:
  /// **'Select Sex'**
  String get selectSex;

  /// No description provided for @pleaseSelectSex.
  ///
  /// In en, this message translates to:
  /// **'Please select your sex'**
  String get pleaseSelectSex;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @req.
  ///
  /// In en, this message translates to:
  /// **'Req.'**
  String get req;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneNumberOptional;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get pleaseSelectCountry;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State / Region'**
  String get selectState;

  /// No description provided for @pleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get pleaseSelectState;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @agreeNewsletter.
  ///
  /// In en, this message translates to:
  /// **'I expressly agree to receive the newsletter'**
  String get agreeNewsletter;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By creating your account you agree to our '**
  String get agreeTerms;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @completeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete Onboarding'**
  String get completeOnboarding;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @streamTab.
  ///
  /// In en, this message translates to:
  /// **'Stream Tab'**
  String get streamTab;

  /// No description provided for @audioTab.
  ///
  /// In en, this message translates to:
  /// **'Audio Tab'**
  String get audioTab;

  /// No description provided for @flick.
  ///
  /// In en, this message translates to:
  /// **'Flicks'**
  String get flick;

  /// No description provided for @celebrate.
  ///
  /// In en, this message translates to:
  /// **'Celebrate'**
  String get celebrate;

  /// No description provided for @stream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get stream;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @celebrateYou.
  ///
  /// In en, this message translates to:
  /// **'Let Us Celebrate You'**
  String get celebrateYou;

  /// No description provided for @welcomeAudienceAwaits.
  ///
  /// In en, this message translates to:
  /// **'Welcome Your Audience Awaits.'**
  String get welcomeAudienceAwaits;

  /// No description provided for @addFamily.
  ///
  /// In en, this message translates to:
  /// **'Add Family'**
  String get addFamily;

  /// No description provided for @searchAndAddFamily.
  ///
  /// In en, this message translates to:
  /// **'Search and add your family members.'**
  String get searchAndAddFamily;

  /// No description provided for @searchByNameOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get searchByNameOrUsername;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent to \"{name}\"'**
  String inviteSent(Object name);

  /// No description provided for @postsTab.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsTab;

  /// No description provided for @careerTab.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get careerTab;

  /// No description provided for @wealthTab.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get wealthTab;

  /// No description provided for @personalTab.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalTab;

  /// No description provided for @publicPersonaTab.
  ///
  /// In en, this message translates to:
  /// **'Public Persona'**
  String get publicPersonaTab;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @relationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationships;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @hobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get hobbies;

  /// No description provided for @lifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyle;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @spirituality.
  ///
  /// In en, this message translates to:
  /// **'Spirituality'**
  String get spirituality;

  /// No description provided for @involvedCauses.
  ///
  /// In en, this message translates to:
  /// **'Involved Causes'**
  String get involvedCauses;

  /// No description provided for @publicImage.
  ///
  /// In en, this message translates to:
  /// **'Public Image'**
  String get publicImage;

  /// No description provided for @controversies.
  ///
  /// In en, this message translates to:
  /// **'Controversies'**
  String get controversies;

  /// No description provided for @fashionStyle.
  ///
  /// In en, this message translates to:
  /// **'Fashion Style'**
  String get fashionStyle;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @tattoos.
  ///
  /// In en, this message translates to:
  /// **'Tattoos'**
  String get tattoos;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @talents.
  ///
  /// In en, this message translates to:
  /// **'Talents'**
  String get talents;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @fanTheoriesInteractions.
  ///
  /// In en, this message translates to:
  /// **'Fan Theories & Interactions'**
  String get fanTheoriesInteractions;

  /// No description provided for @socials.
  ///
  /// In en, this message translates to:
  /// **'Socials'**
  String get socials;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @tabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get tabPeople;

  /// No description provided for @tabFlicks.
  ///
  /// In en, this message translates to:
  /// **'Flicks'**
  String get tabFlicks;

  /// No description provided for @tabPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get tabPlaces;

  /// No description provided for @tabAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get tabAudio;

  /// No description provided for @tabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tabCategories;

  /// No description provided for @tabRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get tabRooms;

  /// No description provided for @tabStream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get tabStream;

  /// No description provided for @tabUhondo.
  ///
  /// In en, this message translates to:
  /// **'Uhondo'**
  String get tabUhondo;

  /// No description provided for @nothingToDisplay.
  ///
  /// In en, this message translates to:
  /// **'Nothing to display'**
  String get nothingToDisplay;

  /// No description provided for @categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories Tab'**
  String get categoriesTab;

  /// No description provided for @roomTab.
  ///
  /// In en, this message translates to:
  /// **'Room Tab'**
  String get roomTab;

  /// No description provided for @noLiveStreams.
  ///
  /// In en, this message translates to:
  /// **'No live streams available'**
  String get noLiveStreams;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get identityVerification;

  /// No description provided for @identityVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please take a clear photo of your government-issued ID or passport. This is required to verify your celebrity status.'**
  String get identityVerificationDesc;

  /// No description provided for @takeFrontPhotoInstruction.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the FRONT of your ID'**
  String get takeFrontPhotoInstruction;

  /// No description provided for @takeBackPhotoInstruction.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the BACK of your ID'**
  String get takeBackPhotoInstruction;

  /// No description provided for @takeFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Front Photo'**
  String get takeFrontPhoto;

  /// No description provided for @takeBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Back Photo'**
  String get takeBackPhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @frontOfId.
  ///
  /// In en, this message translates to:
  /// **'Front of ID:'**
  String get frontOfId;

  /// No description provided for @backOfId.
  ///
  /// In en, this message translates to:
  /// **'Back of ID:'**
  String get backOfId;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get submitForVerification;

  /// No description provided for @verificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Verification submitted!'**
  String get verificationSubmitted;

  /// No description provided for @joinTheCommunitySignUp.
  ///
  /// In en, this message translates to:
  /// **'Join The Community (Sign Up)'**
  String get joinTheCommunitySignUp;

  /// No description provided for @joinTheCommunitySignIn.
  ///
  /// In en, this message translates to:
  /// **'Join The Community (Sign In)'**
  String get joinTheCommunitySignIn;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// No description provided for @addedFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Added family member: {name}'**
  String addedFamilyMember(Object name);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @addWealth.
  ///
  /// In en, this message translates to:
  /// **'Add Wealth'**
  String get addWealth;

  /// No description provided for @addWealthInfo.
  ///
  /// In en, this message translates to:
  /// **'Add your wealth information.'**
  String get addWealthInfo;

  /// No description provided for @addedWealthItem.
  ///
  /// In en, this message translates to:
  /// **'Added wealth item: {name}'**
  String addedWealthItem(Object name);

  /// No description provided for @addDegree.
  ///
  /// In en, this message translates to:
  /// **'Add Degree'**
  String get addDegree;

  /// No description provided for @pleaseFillAllFieldsToAddDegree.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields to add a degree.'**
  String get pleaseFillAllFieldsToAddDegree;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @degreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree (e.g. BSc, MSc, PhD, Masters)'**
  String get degreeLabel;

  /// No description provided for @enterDegree.
  ///
  /// In en, this message translates to:
  /// **'Enter degree'**
  String get enterDegree;

  /// No description provided for @certifyingUniversity.
  ///
  /// In en, this message translates to:
  /// **'Certifying University'**
  String get certifyingUniversity;

  /// No description provided for @enterUniversity.
  ///
  /// In en, this message translates to:
  /// **'Enter university'**
  String get enterUniversity;

  /// No description provided for @yearOfCompletion.
  ///
  /// In en, this message translates to:
  /// **'Year of Completion'**
  String get yearOfCompletion;

  /// No description provided for @enterYear.
  ///
  /// In en, this message translates to:
  /// **'Enter year'**
  String get enterYear;

  /// No description provided for @addedDegrees.
  ///
  /// In en, this message translates to:
  /// **'Added Degrees:'**
  String get addedDegrees;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @openGallery.
  ///
  /// In en, this message translates to:
  /// **'Open Gallery'**
  String get openGallery;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get enterValidAge;

  /// No description provided for @socialUsername.
  ///
  /// In en, this message translates to:
  /// **'{platform} Username'**
  String socialUsername(Object platform);

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @addWealthItem.
  ///
  /// In en, this message translates to:
  /// **'Add Wealth Item'**
  String get addWealthItem;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryValueCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get categoryValueCar;

  /// No description provided for @categoryValueHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get categoryValueHouse;

  /// No description provided for @categoryValueArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get categoryValueArt;

  /// No description provided for @categoryValueProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get categoryValueProperty;

  /// No description provided for @categoryValueJewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get categoryValueJewelry;

  /// No description provided for @categoryValueStocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get categoryValueStocks;

  /// No description provided for @categoryValueBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryValueBusiness;

  /// No description provided for @categoryValueOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryValueOther;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @estimatedValueOptional.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value (optional)'**
  String get estimatedValueOptional;

  /// Category value for dropdown, e.g. Car, House, etc.
  ///
  /// In en, this message translates to:
  /// **'{category}'**
  String categoryValue(Object category);

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get addEducation;

  /// No description provided for @addEducationInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Education Information'**
  String get addEducationInfo;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @houses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get houses;

  /// No description provided for @artCollection.
  ///
  /// In en, this message translates to:
  /// **'Art Collection'**
  String get artCollection;

  /// No description provided for @watchCollection.
  ///
  /// In en, this message translates to:
  /// **'Watch Collection'**
  String get watchCollection;

  /// No description provided for @sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get sign;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'... more'**
  String get more;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'show less'**
  String get showLess;

  /// No description provided for @youRated.
  ///
  /// In en, this message translates to:
  /// **'You rated'**
  String get youRated;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// Snackbar message when user rates a post, with star count.
  ///
  /// In en, this message translates to:
  /// **'You rated {count} stars!'**
  String youRatedStars(Object count);

  /// No description provided for @liveTab.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTab;

  /// No description provided for @recordedTab.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recordedTab;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'What is on your mind?'**
  String get captionHint;

  /// No description provided for @searchCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search Category...'**
  String get searchCategoryHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sw': return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
