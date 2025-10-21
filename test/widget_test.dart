// هذا هو الكود الصحيح لملف test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a9/main.dart'; 
// يجب استيراد هذه الحزمة لتجاوز مشكلة تهيئة Firebase في الاختبار
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'; 

// دالة محاكاة التهيئة التي تحل خطأ [core/no-app]
void setupMockFirebase() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // إخفاء التحذيرات الخاصة بالقنوات غير المهيأة
  MethodChannelFirebase.verify();
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
