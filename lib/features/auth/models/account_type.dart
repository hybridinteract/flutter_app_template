import 'package:json_annotation/json_annotation.dart';

/// Which side of the marketplace an account signed up as.
///
/// Mirrors the backend's `AccountType` (`app/iam/enums.py`). It is fixed at
/// signup and never changes, unlike roles, so branch the UI on this, never on
/// a role name. The backend calls the creator side `influencer` in the API;
/// users read "Creator".
enum AccountType {
  @JsonValue('organization')
  organization('organization'),
  @JsonValue('influencer')
  influencer('influencer');

  const AccountType(this.apiValue);

  /// The value the backend sends and expects.
  final String apiValue;
}
