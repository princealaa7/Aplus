// lib/session_manager.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة المكتبة

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _localSessionId;
  StreamSubscription<DatabaseEvent>? _sessionSubscription;

  // مفتاح لحفظ معرف الجلسة في SharedPreferences
  static const String _sessionIdKey = 'local_session_id';

  void initializeSessionListener(BuildContext context) {
    // الاستماع لحالة المصادقة
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        _localSessionId = prefs.getString(_sessionIdKey);

        // إذا لم يكن هناك معرف جلسة محلي، قم بإنشاء واحد جديد وحفظه
        if (_localSessionId == null) {
          _localSessionId = const Uuid().v4();
          await prefs.setString(_sessionIdKey, _localSessionId!);
        }

        // تأكد من أن المستمع الحالي قد تم إلغاؤه قبل إنشاء واحد جديد
        _sessionSubscription?.cancel();

        final userSessionRef =
            FirebaseDatabase.instance.ref('users/${user.uid}/sessionId');

        // تحديث معرف الجلسة في قاعدة البيانات
        await userSessionRef.set(_localSessionId);

        // البدء في الاستماع للتغييرات في معرف الجلسة
        _sessionSubscription = userSessionRef.onValue.listen((event) {
          final databaseSessionId = event.snapshot.value as String?;

          if (databaseSessionId == null) {
            return;
          }

          // إذا كان معرف الجلسة في قاعدة البيانات لا يطابق المعرف المحلي
          if (databaseSessionId != _localSessionId) {
            // تحقق أن المستخدم ما زال مسجل الدخول قبل عرض النافذة
            if (firebase_auth.FirebaseAuth.instance.currentUser != null) {
              _showForcedMessage(context);
            }
          }
        });
      } else {
        // إذا سجل المستخدم خروجه، قم بإلغاء الاشتراك وحذف المعرف المحلي
        _sessionSubscription?.cancel();
        _localSessionId = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_sessionIdKey);
      }
    });
  }

  void _showForcedMessage(BuildContext context) {
    Future.microtask(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F2027),
                      const Color(0xFF203A43),
                      const Color(0xFF2C5364),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/robot_sad.gif',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'تم تسجيل الدخول من جهاز آخر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'لا يمكنك المتابعة في هذا الجهاز.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void dispose() {
    _sessionSubscription?.cancel();
  }
}
