// هذا هو الكود الصحيح الذي يجب أن يكون في ملف test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a9/main.dart'; 
// يجب إضافة هذه الحزم لتشغيل Firebase في الاختبارات:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'; 
import 'package:firebase_core_testing/firebase_core_testing.dart'; 

// دالة لتهيئة Firebase لبيئة الاختبار
void setupFirebaseTests() {
  // يضمن تهيئة Flutter قبل البدء
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // يقوم بمحاكاة تهيئة Firebase لتجاوز خطأ [core/no-app]
  setupFirebaseCoreMocks(); 
}

void main() {
  // 1. استدعاء تهيئة Firebase قبل بدء أي اختبار
  setupFirebaseTests();
  
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // بعد التهيئة، لن ينهار الكود بسبب Firebase
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
