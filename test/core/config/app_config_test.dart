import 'package:app_template/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test(
      'throws StateError when BASE_URL is empty and no override is provided',
      () {
        expect(
          () => AppConfig.initialize(baseUrl: ''),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('initializes successfully when a valid baseUrl is provided', () {
      AppConfig.initialize(baseUrl: 'https://api-custom.example.com/v1');

      expect(
        AppConfig.instance.baseUrl,
        equals('https://api-custom.example.com/v1'),
      );
    });
  });
}
