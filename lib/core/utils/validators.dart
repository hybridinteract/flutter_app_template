import '../constants/app_constants.dart';

/// Pure-Dart form validators.
///
/// Every message can be overridden. Views pass localized text from
/// `context.l10n`, e.g.
/// `validator: (v) => Validators.email(v, requiredMessage: l10n.validationEmailRequired, message: l10n.validationEmailInvalid)`.
/// The English defaults keep validators usable (and testable) without a
/// BuildContext.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9._-]{3,30}$');

  static String? required(
    String? value, {
    String message = 'This field is required.',
  }) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Email is required.',
    String message = 'Please enter a valid email address.',
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    if (!_emailRegex.hasMatch(value.trim())) return message;
    return null;
  }

  static String? password(
    String? value, {
    int minLength = AppConstants.minPasswordLength,
    String requiredMessage = 'Password is required.',
    String? tooShortMessage,
  }) {
    if (value == null || value.isEmpty) return requiredMessage;
    if (value.length < minLength) {
      return tooShortMessage ??
          'Password must be at least $minLength characters long.';
    }
    return null;
  }

  static final RegExp _upper = RegExp('[A-Z]');
  static final RegExp _lower = RegExp('[a-z]');
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _special = RegExp('[^a-zA-Z0-9]');

  /// Length plus one uppercase, one lowercase, one digit and one special
  /// character: the password policy of the Influen backend
  /// (`app/iam/password_policy.py`). Keep the two in step, or users pass the
  /// form and then fail on the server.
  static String? strongPassword(
    String? value, {
    int minLength = AppConstants.minPasswordLength,
    int maxLength = AppConstants.maxPasswordLength,
    String requiredMessage = 'Password is required.',
    String? tooShortMessage,
    String? tooLongMessage,
    String weakMessage = 'Use an uppercase letter, a lowercase letter, a digit and a special character.',
  }) {
    final lengthError = password(
      value,
      minLength: minLength,
      requiredMessage: requiredMessage,
      tooShortMessage: tooShortMessage,
    );
    if (lengthError != null) return lengthError;
    if (value!.length > maxLength) {
      return tooLongMessage ?? 'Must be at most $maxLength characters.';
    }
    final strong =
        _upper.hasMatch(value) &&
        _lower.hasMatch(value) &&
        _digit.hasMatch(value) &&
        _special.hasMatch(value);
    return strong ? null : weakMessage;
  }

  /// Required, and between [min] and [max] characters after trimming.
  static String? lengthBetween(
    String? value,
    int min,
    int max, {
    String requiredMessage = 'This field is required.',
    String? message,
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    final length = value.trim().length;
    if (length < min || length > max) {
      return message ?? 'Must be between $min and $max characters.';
    }
    return null;
  }

  static String? confirmPassword(
    String? value,
    String? originalPassword, {
    String requiredMessage = 'Please confirm your password.',
    String message = 'Passwords do not match.',
  }) {
    if (value == null || value.isEmpty) return requiredMessage;
    if (value != originalPassword) return message;
    return null;
  }

  static String? phone(
    String? value, {
    String requiredMessage = 'Phone number is required.',
    String message = 'Please enter a valid phone number.',
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    final digits = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!_phoneRegex.hasMatch(digits)) return message;
    return null;
  }

  static String? username(
    String? value, {
    String requiredMessage = 'Username is required.',
    String message = 'Please enter a valid username.',
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    if (!_usernameRegex.hasMatch(value.trim())) return message;
    return null;
  }

  static String? minLength(String? value, int length, {String? message}) {
    if (value == null || value.length < length) {
      return message ?? 'Must be at least $length characters.';
    }
    return null;
  }

  static String? maxLength(String? value, int length, {String? message}) {
    if (value != null && value.length > length) {
      return message ?? 'Must be at most $length characters.';
    }
    return null;
  }
}
