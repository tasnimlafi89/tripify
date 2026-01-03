import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Travel Planner'**
  String get appTitle;

  /// Greeting message on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get searchPlaceholder;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Flights action label
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get flights;

  /// Hotels action label
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// Cars action label
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// Food action label
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// Featured destinations section title
  ///
  /// In en, this message translates to:
  /// **'Featured Destinations'**
  String get featuredDestinations;

  /// See all button text
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// AI powered badge text
  ///
  /// In en, this message translates to:
  /// **'AI Powered'**
  String get aiPowered;

  /// AI planner card title
  ///
  /// In en, this message translates to:
  /// **'Smart Trip Planner'**
  String get smartTripPlanner;

  /// AI planner card description
  ///
  /// In en, this message translates to:
  /// **'Create your perfect itinerary in seconds'**
  String get createPerfectItinerary;

  /// Plan now button text
  ///
  /// In en, this message translates to:
  /// **'Plan Now'**
  String get planNow;

  /// Popular destinations section title
  ///
  /// In en, this message translates to:
  /// **'Popular This Month'**
  String get popularThisMonth;

  /// Trips count suffix
  ///
  /// In en, this message translates to:
  /// **'trips'**
  String get trips;

  /// Explore tab title
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Explore tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover amazing destinations'**
  String get discoverDestinations;

  /// Search destinations placeholder
  ///
  /// In en, this message translates to:
  /// **'Search destinations...'**
  String get searchDestinations;

  /// All category
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Beach category
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get beach;

  /// Mountain category
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get mountain;

  /// City category
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Adventure category
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  /// My trips tab title
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// Trips tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Your upcoming adventures'**
  String get yourUpcomingAdventures;

  /// Upcoming tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Ongoing tab
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// Past tab
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No active trips message
  ///
  /// In en, this message translates to:
  /// **'No Active Trips'**
  String get noActiveTrips;

  /// Ongoing trips empty state description
  ///
  /// In en, this message translates to:
  /// **'Your ongoing trips will appear here'**
  String get ongoingTripsWillAppear;

  /// Days suffix
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Profile tab title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Premium user badge
  ///
  /// In en, this message translates to:
  /// **'Premium Traveler'**
  String get premiumTraveler;

  /// Trips stat label
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsCount;

  /// Countries stat label
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// Photos stat label
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy and security menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// Payment methods menu item
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// View profile menu item
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon!'**
  String featureComingSoon(String feature);

  /// Book flights page title
  ///
  /// In en, this message translates to:
  /// **'Book Flights'**
  String get bookFlights;

  /// Flights page description
  ///
  /// In en, this message translates to:
  /// **'Search and book flights to destinations worldwide. Compare prices and find the best deals.'**
  String get flightsDescription;

  /// Book hotels page title
  ///
  /// In en, this message translates to:
  /// **'Book Hotels'**
  String get bookHotels;

  /// Hotels page description
  ///
  /// In en, this message translates to:
  /// **'Find and book accommodations ranging from budget-friendly to luxury hotels.'**
  String get hotelsDescription;

  /// Rent cars page title
  ///
  /// In en, this message translates to:
  /// **'Rent Cars'**
  String get rentCars;

  /// Cars page description
  ///
  /// In en, this message translates to:
  /// **'Rent vehicles for your trips. Choose from economy to luxury cars.'**
  String get carsDescription;

  /// Discover food page title
  ///
  /// In en, this message translates to:
  /// **'Discover Food'**
  String get discoverFood;

  /// Food page description
  ///
  /// In en, this message translates to:
  /// **'Find the best restaurants and local cuisine at your destination.'**
  String get foodDescription;

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Recent searches section title
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// Popular destinations section title
  ///
  /// In en, this message translates to:
  /// **'Popular Destinations'**
  String get popularDestinations;

  /// Search results section title
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Privacy setting
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// About setting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Get started button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Social login separator text
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign in prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// First onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Explore the Future'**
  String get onboardingTitle1;

  /// First onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'AI-powered travel planning that crafts your perfect journey in seconds'**
  String get onboardingDesc1;

  /// Second onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Smart Itineraries'**
  String get onboardingTitle2;

  /// Second onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Personalized routes, real-time updates, and seamless booking all in one place'**
  String get onboardingDesc2;

  /// Third onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Travel Smarter'**
  String get onboardingTitle3;

  /// Third onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Your next adventure awaits — let\'s plan the trip of a lifetime'**
  String get onboardingDesc3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
