import 'package:app_template/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test(
      'required should return error message when value is null or empty',
      () {
        expect(Validators.required(null), isNotNull);
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
        expect(Validators.required('valid input'), isNull);
      },
    );

    test('email should validate standard email formats', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('user@domain'), isNotNull);
      expect(Validators.email('test.user@example.com'), isNull);
      expect(Validators.email('user123@sub.domain.org'), isNull);
    });

    test('strongPassword mirrors the backend password policy', () {
      expect(Validators.strongPassword(null), isNotNull);
      expect(Validators.strongPassword('Ab1!'), isNotNull); // too short
      expect(Validators.strongPassword('alllower1!'), isNotNull);
      expect(Validators.strongPassword('ALLUPPER1!'), isNotNull);
      expect(Validators.strongPassword('NoDigits!!'), isNotNull);
      expect(Validators.strongPassword('NoSpecial12'), isNotNull);
      expect(Validators.strongPassword('A1!${'a' * 130}'), isNotNull);
      expect(Validators.strongPassword('Passw0rd!'), isNull);
    });

    test('lengthBetween checks the trimmed length', () {
      expect(Validators.lengthBetween(null, 2, 5), isNotNull);
      expect(Validators.lengthBetween('   ', 2, 5), isNotNull);
      expect(Validators.lengthBetween(' a ', 2, 5), isNotNull);
      expect(Validators.lengthBetween('abcdef', 2, 5), isNotNull);
      expect(Validators.lengthBetween(' ab ', 2, 5), isNull);
    });

    test('password should validate minimum length requirement', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('longerPassword123!'), isNull);
    });

    test('confirmPassword should match original password', () {
      expect(Validators.confirmPassword(null, 'secret'), isNotNull);
      expect(Validators.confirmPassword('different', 'secret'), isNotNull);
      expect(Validators.confirmPassword('secret', 'secret'), isNull);
    });

    test('phone should validate telephone formats', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('+1234567890'), isNull);
      expect(Validators.phone('123-456-7890'), isNull);
    });

    test('username should validate format and length', () {
      expect(Validators.username(null), isNotNull);
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('john_doe'), isNull);
      expect(Validators.username('user.name-123'), isNull);
    });
  });
}
