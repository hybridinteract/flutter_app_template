import 'package:app_template/core/utils/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const delay = Duration(milliseconds: 300);

  group('Debouncer', () {
    // testWidgets runs in a fake-time zone, so tester.pump moves the clock.
    testWidgets('runs only the last action, once calls stop for duration', (
      tester,
    ) async {
      final debouncer = Debouncer(duration: delay);
      addTearDown(debouncer.dispose);
      final calls = <String>[];

      debouncer.run(() => calls.add('a'));
      await tester.pump(const Duration(milliseconds: 100));
      debouncer.run(() => calls.add('ab'));
      await tester.pump(const Duration(milliseconds: 100));
      debouncer.run(() => calls.add('abc'));

      await tester.pump(const Duration(milliseconds: 299));
      expect(calls, isEmpty);
      expect(debouncer.isPending, isTrue);

      await tester.pump(const Duration(milliseconds: 1));
      expect(calls, ['abc']);
      expect(debouncer.isPending, isFalse);
    });

    testWidgets('cancel and dispose drop the pending action', (tester) async {
      final debouncer = Debouncer(duration: delay);
      var calls = 0;

      debouncer.run(() => calls++);
      debouncer.cancel();
      await tester.pump(delay);
      expect(calls, 0);

      debouncer.run(() => calls++);
      debouncer.dispose();
      await tester.pump(delay);
      expect(calls, 0);
    });
  });
}
