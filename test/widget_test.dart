// هذا هو الكود الصحيح لملف test/widget_test.dart
// يحل مشكلة الـ mocking لـ Firebase بآلية القنوات الأساسية

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // يجب استيراد هذه الحزمة
import 'package:flutter_test/flutter_test.dart';

import 'package:a9/main.dart'; 

void main() {
  // 1. تهيئة بيئة الاختبار والتأكد من تفعيلها
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // 2. إعداد قناة Mock لـ Firebase Core
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');
  
  // 3. اعتراض جميع استدعاءات Firebase ومنع الانهيار
  // هذا هو الجزء الذي يحل مشكلة الـ mocking:
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel, 
    (MethodCall methodCall) async {
      // محاكاة نتيجة التهيئة الأساسية لـ Firebase
      if (methodCall.method == 'Firebase#initializeCore') {
        return <Map<String, dynamic>>[]; // إرجاع قائمة فارغة يعني نجاح التهيئة الوهمية
      }
      return null;
    }
  );

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // بعد التهيئة الوهمية، يجب أن ينجح هذا السطر الآن
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
