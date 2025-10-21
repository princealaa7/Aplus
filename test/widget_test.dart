// هذا هو الكود الصحيح والأكثر أمانًا لملف test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // يجب استيراد هذه الحزمة
import 'package:flutter_test/flutter_test.dart';

import 'package:a9/main.dart'; 
// لا نحتاج إلى استيراد حزم firebase_core_... المعقدة هنا بعد الآن!

// دالة محاكاة التهيئة التي تستخدم الخدمات الأساسية (الأكثر موثوقية)
void setupMockFirebase() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // قم بإعداد قناة الخدمات لمنع الانهيار بسبب Firebase.initializeApp()
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');

  // هذه الدالة تتجاهل أي محاولة لاستدعاء Firebase قبل التهيئة
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, 
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [{'name': 'default', 'options': {}}];
      }
      return null;
    }
  );
}

void main() {
  // 1. استدعاء دالة التهيئة قبل بدء أي اختبار
  setupMockFirebase();
  
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // لن ينهار هنا بسبب Firebase بعد الآن.
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
