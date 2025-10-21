// هذا هو الكود الصحيح لملف test/widget_test.dart
// يحل مشكلة الـ mocking لـ Firebase بآلية القنوات الأساسية

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ضروري لـ MethodChannel
import 'package:flutter_test/flutter_test.dart';

import 'package:a9/main.dart'; 

void main() {
  // استخدم setUpAll لتنفيذ التهيئة مرة واحدة قبل جميع الاختبارات
  setUpAll(() {
    // 1. تأكد من تهيئة Flutter قبل كل شيء
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // 2. إعداد قناة Mock لـ Firebase Core
    const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');
    
    // 3. اعتراض جميع استدعاءات Firebase#initializeCore ومنع الانهيار
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel, 
      (MethodCall methodCall) async {
        // إذا كان الاستدعاء هو محاولة التهيئة، أعد نتيجة نجاح وهمية.
        if (methodCall.method == 'Firebase#initializeCore') {
          return <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'default',
              'options': <String, dynamic>{
                'apiKey': 'mock_api_key',
                'appId': 'mock_app_id',
                'projectId': 'mock_project_id',
              },
              'pluginConstants': <String, dynamic>{},
            },
          ];
        }
        // تجاهل أي استدعاءات أخرى لقناة Firebase Core
        return null; 
      }
    );
  });
  
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // بعد التهيئة الوهمية، سيتمكن التطبيق من البناء هنا
    await tester.pumpWidget(const MyApp());

    // ... بقية اختباراتك
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
