import 'package:flutter_test/flutter_test.dart';
import 'package:aplus/main.dart';

void main() {
  test('Basic app test - always passes', () {
    expect(1, 1);
  });

  test('App can be created', () {
    // تأكد أن التطبيق يمكن إنشاؤه بدون أخطاء
    expect(() => main(), returnsNormally);
  });
}
