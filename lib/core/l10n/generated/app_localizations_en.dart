// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonEmailHint => 'user@example.com';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonSomethingWentWrong => 'Something went wrong';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorPageNotFoundTitle => '404 - Page Not Found';

  @override
  String errorPageNotFoundMessage(String path) {
    return 'The page \"$path\" does not exist.';
  }

  @override
  String get errorBackToHome => 'Back to Home';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationEmailRequired => 'Email is required.';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Password is required.';

  @override
  String validationPasswordTooShort(int minLength) {
    return 'Password must be at least $minLength characters long.';
  }

  @override
  String get validationConfirmPasswordRequired =>
      'Please confirm your password.';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get validationPasswordWeak =>
      'Use an uppercase letter, a lowercase letter, a digit and a special character.';

  @override
  String validationPasswordTooLong(int maxLength) {
    return 'Password must be at most $maxLength characters long.';
  }

  @override
  String validationLengthBetween(int min, int max) {
    return 'Must be between $min and $max characters.';
  }

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authSignInSubtitle => 'Sign in to access your account';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authGetStarted => 'Get Started';

  @override
  String get authRegisterSubtitle => 'Create a new account to continue';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'John Doe';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authAccountTypeLabel => 'I am a';

  @override
  String get authAccountTypeCreator => 'Creator';

  @override
  String get authAccountTypeBrand => 'Brand';

  @override
  String get authOrganizationName => 'Organization Name';

  @override
  String get authOrganizationNameHint => 'Acme Pvt Ltd';

  @override
  String get authSocialHandle => 'Social Handle';

  @override
  String get authSocialHandleHint => '@yourhandle';

  @override
  String get authVerifyEmailTitle => 'Verify Your Email';

  @override
  String authVerifyEmailSubtitle(String email) {
    return 'Enter the code we sent to $email';
  }

  @override
  String get authVerificationCode => 'Verification Code';

  @override
  String get authVerificationCodeHint => '123456';

  @override
  String get authVerify => 'Verify';

  @override
  String get authNoCode => 'Didn\'t get the code? ';

  @override
  String get authResendCode => 'Resend Code';

  @override
  String get authCodeResent => 'A new code is on its way.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeLogout => 'Logout';

  @override
  String get homeSignOut => 'Sign Out';

  @override
  String get homeDefaultUserName => 'User';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name!';
  }
}
