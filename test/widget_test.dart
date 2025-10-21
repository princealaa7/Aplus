// هذا هو الكود النهائي لملف test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:a9/main.dart'; 
// يجب استيراد هذه الحزمة لتوفير دالة setupFirebaseCoreMocks
import 'package:firebase_core_testing/firebase_core_testing.dart'; 


void main() {
  // 1. استخدام setupAll لتهيئة Firebase مرة واحدة قبل بدء جميع الاختبارات
  setUpAll(() async {
    // يضمن تهيئة Flutter قبل البدء
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // يقوم بمحاكاة تهيئة Firebase لجميع الخدمات (Core, Auth, إلخ)
    // هذا هو الخط الذي يحل المشكلة جذريًا:
    setupFirebaseCoreMocks(); 
  });
  
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
