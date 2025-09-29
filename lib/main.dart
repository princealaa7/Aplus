// main.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:io'; // يتيح لك التعامل مع ملفات النظام
import 'package:image_picker/image_picker.dart'; // المكتبة التي أضفتها في الخطوة السابقة

// ===== شاشة بوابة المصادقة الجديدة =====

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const WelcomeRobotPage();
        }

        return const LoginPage();
      },
    );
  }
}

final Map<int, Map<int, String>> chapterLessonContents = {
  1: {
    1: '"Toe is bleeding" إصبع قدمي ينزف (كلمات مهمة)\nالفرق بين: pain - sore - hurt',
    2: 'Past Simple Tense: زمن الماضي البسيط\nPast Continuous Tense: زمن الماضي المستمر\nالعلاقة بين الماضي البسيط والماضي المستمر',
    3: 'قطعة:  Ammar\nالصفات المنتهية بـ -ed و -ing\nAdjectives and Adverbs: الصفات والظروف',
    4: 'Present Simple: المضارع البسيط\nPhrasal Verbs: الأفعال المركبة\nPrefixes (meaning not): إضافات النفي في بداية الكلمة',
    5: 'Imperative: جملة الأمر\nCountable & Uncountable Nouns: الأسماء المعدودة وغير المعدودة\nExpressions of Quantity: تعابير الكمية',
    6: 'Used to: اعتاد على\nالمقارنة بين الماضي والحاضر بـ Used to\nUsed to مع الماضي البسيط والمضارع البسيط',
    7: 'Let’s start with diet: دعنا نبدأ بالنظام الغذائي',
    8: 'Cigarette advertising should be illegal: يجب حظر إعلانات السجائر (إنشاء)',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: '"I will always be proud of him": قطعة (سأكون دائمًا فخورًا به)',
  },
  2: {
    1: 'كلمات مهمة عن القانون والنظام: "Law and Order"',
    2: 'قطعة: وظائف ضباط الشرطة "A Police Officer\'s Duties"\nNecessity and Non-Necessity: الضرورة وعدم الضرورة',
    3: 'Polite Request: الطلب المؤدب\nSuggestions: الاقتراحات\nOffers: العروض\nAdvice: النصيحة',
    4: 'Expectation: التوقع\nالمختصرات',
    5: 'Military Jobs: وظائف عسكرية',
    6: 'Causative Verbs: الأفعال السببية (have / get / make)',
    7: 'A Safety Brochure: كتيب أمان',
    8: 'An Advice to a Friend to Get a Job: إنشاء حول الحصول على وظيفة',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: 'Security Technology (Radar): تكنولوجيا الأمن (رادار)',
  },
  3: {
    1: 'أسماء المهن\nJob Definition: تعريف المهنة',
    2: 'Conditional Sentences: الجمل الشرطية',
    3: 'تمارين عن الجمل الشرطية',
    4: 'Reported Speech: الكلام المنقول',
    5: 'Regret: الندم',
    6: 'تمارين عن الجمل الشرطية',
    7: '"Learn English in the UK": تعلم في المملكة المتحدة',
    8: 'The Advantages of Studying English in Britain: فوائد الدراسة في بريطانيا (إنشاء)',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: 'Focus on Careers - Conference Interpreter: مترجم المؤتمرات',
  },
  4: {
    1: 'A Company You Have Recently Set Up (إنشاء)\nتأسيس شركة قمت بإنشائها مؤخرًا\nBad Day / Terrible Day (إنشاء)\nيوم سيئ حقيقي',
    2: 'تمارين مهم',
  },
  5: {
    1: 'Compound nouns: الأسماء المركبة',
    2: 'Present perfect simple : زمن المضارع التام البسيط\n(never, ever, since, for, already, just, so far, yet)',
    3: 'Present Perfect Continuous : زمن المضارع التام المستمر\nHow long',
    4: 'has been / has gone : استخدام',
    5: 'Past Perfect Simple : زمن الماضي التام\nالعلاقة بين الماضي البسيط والماضي التام',
    6: '" The atmosphere was really peaceful" قطعة كانت الأجواء هادئة حقًا',
    7: 'Defining and non-Defining relative clause العبارات الوصلية',
    8: '" A wonderful holiday l have had" انشاء عطلة رائعة',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: '" Why are holidays so important" قطعة (لماذا تعتبر العطلات مهمة للغاية؟)',
  },
  6: {
    1: 'What does it all mean مفردات جديدة',
    2: 'passive voice: المبني للمجهول',
    3: 'Meet a banker',
    4: 'Conditional sentences : تمارين عن الجمل الشرطية',
    5: 'Conditional sentences : تمارين عن الجمل الشرطية',
    6: 'تعاريف',
    7: 'Formal and informal letters الرسائل الرسمية وغير الرسمية',
    8: 'a letter to your bank to complain about a withdrawal رسالة شكوى على البنك',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: 'Making money: جني الأموال',
  },
  7: {
    1: 'إضافات\nWhat can I study مفردات جديدة',
    2: 'Future المستقبل\n- Future simple: المستقبل البسيط\n  المضارع المستمر للمستقبل\n "going to" for future\n المستقبل المستمر\n المضارع البسيط للمستقبل',
    3: 'Work today قطعة',
    4: 'Future in the past :المستقبل في الماضي',
    5: 'Volunteers at the Children\'s Hospital',
    6: 'Learning experiences',
    7: '" Books and the Internet"',
    8: 'Studying while you are working انشاء الدراسة إثناء العمل',
    9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
    10: 'Using the Library : أستعمال المكتبات',
  },
  8: {
    1: '(de/ation) البادئات واللاحقات',
    2: '" A renewable resources Wind power : طاقة الرياح',
    3: '" improve the environment." انشاء تحسين البيئة',
    4: 'تمارين',
  },
  9: {
    1: 'ألادب\n The Canary الكناري',
    2: 'الافعال الشاذه',
    3: 'كيفية الإجابة على القطعة الخارجية',
  },
};

// تأثير التمايل للروبوت
class RobotBounceAnimation extends StatefulWidget {
  final Widget child;

  const RobotBounceAnimation({super.key, required this.child});

  @override
  State<RobotBounceAnimation> createState() => _RobotBounceAnimationState();
}

class _RobotBounceAnimationState extends State<RobotBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// تأثير النبض لدائرة التحميل
class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({super.key, required this.child});

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ===============================================
// 1. نموذج (Model) السؤال - تم الإضافة
// ===============================================
class Question {
  final String text;
  final String type;
  final dynamic correctAnswer;
  final List<String>? options;
  final List<String>? keywords;
  final int maxScore;
  final int requiredWordCount; // إضافة جديدة لعدد الكلمات المطلوبة
  final Map<String, double> rubric; // معايير التصحيح

  Question({
    required this.text,
    required this.type,
    required this.correctAnswer,
    this.options,
    this.keywords,
    this.maxScore = 1,
    this.requiredWordCount = 100, // قيمة افتراضية
    this.rubric = const {
      // معايير افتراضية
      'content': 5.0,
      'organization': 3.0,
      'vocabulary': 4.0,
      'grammar': 6.0,
      'style': 2.0
    },
  });
}

// main.dart

/// ===============================================
// 2. المحلل (Evaluator) - الكود المصحح والنهائي
// ===============================================
// ignore: unused_element
class _EssayEvaluator {
  static double evaluate({
    required String answer,
    required List<String>? keywords,
    required int requiredWordCount,
    required Map<String, double> rubric,
  }) {
    // 1. حساب كل درجة بناءً على المعايير
    final double contentScore = _evaluateContentWithSynonyms(
      answer: answer,
      keywords: keywords ?? [],
      maxScore: rubric['content'] ?? 5.0,
    );

    final double vocabularyScore = _evaluateVocabulary(
      answer: answer,
      maxScore: rubric['vocabulary'] ?? 4.0,
    );

    final double grammarScore = _evaluateGrammar(
      answer: answer,
      maxScore: rubric['grammar'] ?? 6.0,
    );

    // 2. درجات التنظيم والأسلوب تؤخذ كاملة
    // (لأنها تتطلب تقييمًا بشريًا أو NLP متقدم غير موجود حاليًا)
    final double organizationScore = rubric['organization'] ?? 3.0;
    final double styleScore = rubric['style'] ?? 2.0;

    // 3. جمع الدرجات الجزئية
    double finalScore = contentScore +
        vocabularyScore +
        grammarScore +
        organizationScore +
        styleScore;

    // 4. تطبيق خصم الكلمات
    final int wordCount = answer.split(RegExp(r'\s+')).length;
    final double wordCountRatio =
        _calculateWordCountRatio(wordCount, requiredWordCount);
    finalScore *= wordCountRatio;

    // 5. ضمان أن النتيجة النهائية لا تتجاوز المجموع الكامل
    final double maxTotalScore =
        rubric.values.fold(0.0, (sum, score) => sum + score);

    print('نتيجة الإنشاء النهائية هي: $finalScore');

    return min(finalScore, maxTotalScore);
  }

  Future<void> calculateAndSaveScore({
    required String answer,
    required List<String>? keywords,
    required int requiredWordCount,
    required Map<String, double> rubric,
  }) async {
    // استدعاء دالة التقييم أولاً
    _EssayEvaluator.evaluate(
      answer: answer,
      keywords: keywords,
      requiredWordCount: requiredWordCount,
      rubric: rubric,
    );
  }

  // الدوال المساعدة (بدون تغيير)
// استبدل الدالة الحالية بهذا الكود
  static double _calculateWordCountRatio(int actual, int required) {
    // حساب النسبة المئوية لعدد الكلمات المكتوبة
    double percentage = (actual / required) * 100;

    // تطبيق نظام الخصم الجديد بناءً على الجدول المطلوب
    if (percentage >= 100) {
      return 1.0; // 100% أو أكثر - لا خصم
    } else if (percentage >= 90) {
      return 0.95; // خصم 5%
    } else if (percentage >= 80) {
      return 0.90; // خصم 10%
    } else if (percentage >= 70) {
      return 0.90; // 70-79% - خصم 10% (2 من 20)
    } else if (percentage >= 60) {
      return 0.80; // 60-69% - خصم 20% (4 من 20)
    } else if (percentage >= 50) {
      return 0.60; // 50-59% - خصم 40% (8 من 20)
    } else if (percentage >= 40) {
      return 0.50; // 40-49% - خصم 50% (10 من 20)
    } else if (percentage >= 30) {
      return 0.30; // 30-39% - خصم 70% (14 من 20)
    } else if (percentage >= 20) {
      return 0.20; // 20-29% - خصم 80% (16 من 20)
    } else if (percentage >= 10) {
      return 0.10; // 10-19% - خصم 90% (18 من 20)
    } else if (percentage > 0) {
      return 0.05; // أقل من 10% - خصم 95% (درجة 1 من 20)
    } else {
      return 0.05; // لم يكتب شيئاً - درجة 1 من 20
    }
  }

  static double _evaluateContentWithSynonyms({
    required String answer,
    required List<String> keywords,
    required double maxScore,
  }) {
    final synonyms = _buildSynonymsMap();
    int matchedPoints = 0;
    for (final keyword in keywords) {
      final keywordVariations = synonyms[keyword.toLowerCase()] ?? [keyword];
      final found = keywordVariations
          .any((variation) => answer.toLowerCase().contains(variation));
      if (found) matchedPoints++;
    }
    return (matchedPoints / (keywords.length / 2)) * maxScore;
  }

  static Map<String, List<String>> _buildSynonymsMap() {
    return {
      'harmful': ['damaging', 'detrimental', 'injurious', 'destructive'],
      'smokers': ['tobacco users', 'cigarette users', 'nicotine addicts'],
      'passive': ['involuntary', 'second-hand', 'unintentional'],
      'illegal': ['unlawful', 'prohibited', 'banned', 'forbidden'],
      'ban': ['prohibition', 'embargo', 'restriction'],
      'teenagers': ['adolescents', 'youth', 'minors', 'young adults'],
      'influence': ['impact', 'effect', 'sway', 'affect'],
      'cancer': ['carcinoma', 'malignancy', 'tumor'],
      'health': ['well-being', 'physical condition'],
      'advertisements': ['ads', 'commercials', 'promotions', 'marketing'],
      'lung cancer': ['pulmonary cancer', 'respiratory carcinoma'],
      'children': ['kids', 'minors', 'youngsters'],
      'media': ['press', 'broadcasting', 'mass media'],

      // مرادفات الفصل الثاني (الوظائف)
      'should': ['ought to', 'must', 'need to'],
      'shouldn\'t': ['ought not to', 'must not', 'avoid'],
      'interview': ['meeting', 'assessment', 'evaluation'],
      'dress': ['attire', 'clothing', 'outfit'],
      'time': ['punctual', 'on schedule', 'timely'],
      'confident': ['self-assured', 'poised', 'self-confident'],
      'advice': ['guidance', 'recommendations', 'suggestions'],
      'job': ['position', 'employment', 'occupation'],
      'prepare': ['get ready', 'make ready', 'arrange'],
      'skills': ['abilities', 'competencies', 'expertise'],
      'qualifications': ['credentials', 'certifications', 'requirements'],
      'experience': ['background', 'history', 'exposure'],
      'employer': ['manager', 'boss', 'recruiter'],
      'resume': ['CV', 'curriculum vitae', 'application'],
      'punctual': ['on time', 'timely', 'prompt'],

      // Unit 3: Advantages of studying English in Britain
      'advantages': ['benefits', 'perks', 'merits', 'gains', 'pros'],
      'studying': ['learning', 'pursuing', 'mastering', 'acquiring'],
      'Britain': ['UK', 'United Kingdom', 'England'],
      'practice': ['rehearse', 'train', 'exercise', 'improve'],
      'pronunciation': ['accent', 'articulation', 'enunciation'],
      'vocabulary': ['lexicon', 'word bank', 'terminology'],
      'lifestyle': ['way of life', 'culture', 'customs', 'traditions'],
      'native teachers': ['local instructors', 'British educators'],

      // Unit 4 (1): Setting up a new company
      'email': ['correspondence', 'message', 'letter'],
      'new company': ['startup', 'venture', 'enterprise', 'business'],
      'set up': ['establish', 'found', 'launch', 'start'],
      'investment': ['capital', 'funding', 'finance'],
      'profit': ['earnings', 'revenue', 'gain', 'returns'],
      'product': ['goods', 'merchandise', 'items'],
      'business': ['company', 'firm', 'corporation'],

      // Unit 4 (2): A bad day
      'bad day': ['awful day', 'horrible day', 'miserable day'],
      'terrible day': ['dreadful', 'ghastly', 'horrid'],
      'went wrong': ['failed', 'didn\'t work out', 'backfired'],
      'late': ['delayed', 'tardy', 'behind schedule'],
      'accident': ['mishap', 'incident', 'misadventure'],
      'frustrating': ['annoying', 'upsetting', 'disheartening'],
      'unlucky': ['unfortunate', 'jinxed', 'cursed'],

      // Unit 5 (1): A wonderful holiday
      'travel magazine': ['tourism publication', 'travel journal'],
      'article': ['piece', 'essay', 'report'],
      'wonderful holiday': [
        'fantastic trip',
        'amazing vacation',
        'great getaway'
      ],
      'trip': ['journey', 'excursion', 'tour'],
      'package deal': ['all-inclusive trip', 'bundled offer'],
      'sightseeing': ['touring', 'exploring', 'visiting landmarks'],
      'souvenirs': ['mementos', 'keepsakes', 'trinkets'],
      'memorable': ['unforgettable', 'significant', 'notable'],

      // Unit 5 (2): Advice for tourists in Iraq
      // ignore: equal_keys_in_map
      'advice': ['tips', 'guidance', 'recommendations', 'suggestions'],
      'tourists': ['visitors', 'travellers', 'sightseers'],
      'historical places': ['ruins', 'monuments', 'heritage sites'],
      'ancient civilizations': ['old cultures', 'past societies'],
      'holy shrines': ['sacred sites', 'religious monuments'],
      'nature': ['scenery', 'landscape', 'environment'],
      'money': ['currency', 'cash', 'funds'],

      // Unit 6: Letter of complaint to the bank
      'letter': ['correspondence', 'note', 'communication'],
      'bank': ['financial institution', 'credit union'],
      'complain': ['protest', 'object', 'report a problem'],
      'withdrawal': ['debit', 'transaction', 'deduction'],
      'statement': ['bank record', 'account summary'],
      'transaction': ['operation', 'action'],
      'unauthorized': ['fraudulent', 'illegal', 'unapproved'],

      // Unit 7: Studying while working
      'essay': ['composition', 'paper', 'article'],
      'opinion': ['viewpoint', 'perspective', 'belief'],
      // ignore: equal_keys_in_map
      'studying': ['learning', 'pursuing education'],
      'working': ['employment', 'career', 'job'],
      'hard work': ['effort', 'diligence', 'dedication'],
      'career advancement': ['professional growth', 'career progression'],
      'higher degree': ['advanced degree', 'graduate degree'],
      'salary': ['wage', 'income', 'earnings'],
      'benefits': ['advantages', 'rewards', 'gains'],

      // Unit 8: Improving the environment
      'environment': ['ecosystem', 'surroundings', 'planet'],
      'improve': ['enhance', 'better', 'upgrade'],
      'healthy': ['safe', 'green', 'sustainable'],
      'clean': ['pure', 'unpolluted', 'pristine'],
      'recycle': ['reuse', 'repurpose'],
      'renewable energy': ['green energy', 'sustainable power'],
      'plant trees': ['afforestation', 'reforestation'],
      'public transport': ['mass transit', 'public transportation'],
      'pollution': ['contamination', 'smog', 'waste'],
    };
  }

  static double _evaluateVocabulary({
    required String answer,
    required double maxScore,
  }) {
    final List<String> words =
        answer.split(' ').map((word) => word.toLowerCase()).toSet().toList();
    final int uniqueWordsCount = words.length;
    final int totalWordsCount = answer.split(' ').length;
    if (totalWordsCount == 0) return 0;
    final double diversityRatio = uniqueWordsCount / totalWordsCount;
    return min(diversityRatio, 1.0) * maxScore;
  }

  static double _evaluateGrammar({
    required String answer,
    required double maxScore,
  }) {
    int commonErrors = 0;
    if (answer.contains('  ')) {
      commonErrors++;
    }
    final double score = maxScore - (commonErrors * 1.0);
    return max(0, score);
  }
}

// ===============================================
// 2. بيانات الاختبارات لجميع الفصول - تم الإضافة
// ===============================================
final Map<int, List<Question>> allQuizzes = {
  // الفصل الأول: أساسيات Flutter
  1: [
    // Textbook Passages

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. We (drive) fast when we (hear) a loud noise. (Correct the verbs)',
      type: 'text_input',
      correctAnswer: 'We were driving fast when we heard a loud noise',
    ),
    Question(
      text:
          '2. An average of eight hours a night is about right. (Use imperative to give advice)',
      type: 'text_input',
      correctAnswer: 'Get enough sleep',
    ),
    Question(
      text:
          '3. There were only (a few / a little) people at the party. (choose)',
      type: 'dropdown',
      options: ['a few', 'a little'],
      correctAnswer: 'a few',
    ),
    Question(
      text: '4. I like these shoes. Can I (try/on/them?) (Put in order)',
      type: 'text_input',
      correctAnswer: 'Can I try them on?',
    ),
    Question(
      text:
          '5. I (like) travelling, but now I (not/like) it anymore. (Use: used to)',
      type: 'text_input',
      correctAnswer:
          'I used to like travelling, but now I don\'t like it anymore',
    ),
    Question(
      text:
          '6. Cities (crowded). (use "than" to compare life today with life 50 years ago)',
      type: 'text_input',
      correctAnswer: 'Cities are more crowded than they used to be',
    ),
    Question(
      text: '7. Sarah (carefully, careful) lifted the box. (choose)',
      type: 'dropdown',
      options: ['carefully', 'careful'],
      correctAnswer: 'carefully',
    ),
    Question(
      text:
          '8. She is not very (interested / interesting) in fashion. (choose)',
      type: 'dropdown',
      options: ['interested', 'interesting'],
      correctAnswer: 'interested',
    ),
    Question(
      text: '9. How (many/much) apples do we need? (choose)',
      type: 'dropdown',
      options: ['many', 'much'],
      correctAnswer: 'many',
    ),

    // Vocabulary and spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. She doesn\'t play tennis. She has _________ her right arm. (Complete with: hurts, broken, pills, pain, faint)',
      type: 'dropdown',
      options: ['hurts', 'broken', 'pills', 'pain', 'faint'],
      correctAnswer: 'broken',
    ),
    Question(
      text:
          '2. Where exactly is the _________ and how long have you had it? (Complete with: hurts, broken, pills, pain, faint)',
      type: 'dropdown',
      options: ['hurts', 'broken', 'pills', 'pain', 'faint'],
      correctAnswer: 'pain',
    ),
    Question(
      text:
          '3. My back _________ all time. It only feels Ok when I am lying down. (Complete with: hurts, broken, pills, pain, faint)',
      type: 'dropdown',
      options: ['hurts', 'broken', 'pills', 'pain', 'faint'],
      correctAnswer: 'hurts',
    ),
    Question(
      text:
          '4. I feel dizzy. I think I am going to _________ (Complete with: hurts, broken, pills, pain, faint)',
      type: 'dropdown',
      options: ['hurts', 'broken', 'pills', 'pain', 'faint'],
      correctAnswer: 'faint',
    ),
    Question(
      text:
          '5. You have to take two of these _________ three times a day (Complete with: hurts, broken, pills, pain, faint)',
      type: 'dropdown',
      options: ['hurts', 'broken', 'pills', 'pain', 'faint'],
      correctAnswer: 'pills',
    ),
    Question(
      text:
          '6. joint in the arm, s_________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'shoulder',
    ),
    Question(
      text:
          '7. polite, impolite; usual, _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'unusual',
    ),
    Question(
      text:
          '8. big, bigger; dangerous, _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'more dangerous',
    ),
    Question(
      text:
          '9. successfully, successful; thankfully, _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'thankful',
    ),
  ],

  // الفصل الثاني: أساسيات Widgets
  2: [
    // Textbook Passages
    Question(
      text: 'A- Textbook Passages \n  \n 1. Why people have to follow the law?',
      type: 'text_input',
      correctAnswer: 'To live safely',
    ),
    Question(
      text: '2. Why do police use radar speed gun?',
      type: 'text_input',
      correctAnswer: 'To catch speeders',
    ),
    Question(
      text: '3. How can drivers avoid radar speed gun?',
      type: 'text_input',
      correctAnswer: 'By using radar detectors',
    ),
    Question(
      text:
          '4. Police must be trained to use radar gun correctly. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text: '5. Police departments don\'t use radar speed gun. (true/false)',
      type: 'true_false',
      correctAnswer: false,
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. This is a new computer, I think it is faster than others (re-write with should or shouldn\'t)',
      type: 'text_input',
      correctAnswer:
          'This is a new computer, so it should be faster than the other one',
    ),
    Question(
      text:
          '2. I asked somebody to cut my hair. (rewrite using the correct form of had)',
      type: 'text_input',
      correctAnswer: 'I had my hair cut',
    ),
    Question(
      text: '3. Take a taxi to the airport (make suggestion)',
      type: 'text_input',
      correctAnswer: 'Let\'s take a taxi',
    ),
    Question(
      text: '4. Give me your passport. (polite request)',
      type: 'text_input',
      correctAnswer: 'Could you give me your passport, please?',
    ),
    Question(
      text: '5. Keep your passport is a safe place (give an advice)',
      type: 'text_input',
      correctAnswer: 'You should keep your passport is a safe place',
    ),
    Question(
      text: '6. ___________ I ask who\'s calling? (will/may)',
      type: 'dropdown',
      options: ['will', 'may'],
      correctAnswer: 'may',
    ),
    Question(
      text:
          '7. Please put out your cigarette. You __________ smoke in the police (must/mustn\'t)',
      type: 'dropdown',
      options: ['must', 'mustn\'t'],
      correctAnswer: 'mustn\'t',
    ),
    Question(
      text:
          '8. Abla needn\'t ____ to the supermarket today because Dana went yesterday (go/to go)',
      type: 'dropdown',
      options: ['go', 'to go'],
      correctAnswer: 'to go',
    ),
    Question(
      text: '9. _________ talk to Mr. Hamza? (I want to talk/Could I speak to)',
      type: 'dropdown',
      options: ['I want to talk', 'Could I speak to'],
      correctAnswer: 'Could I speak to',
    ),
    Question(
      text:
          '10. Police officers __________ prevent crimes (must/don\'t have to)',
      type: 'dropdown',
      options: ['must', 'don\'t have to'],
      correctAnswer: 'must',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. When the police got to the crime scene, they found footprints and _________ (Complete with: Obey, fingerprints, branches, arrested, footprints)',
      type: 'dropdown',
      options: ['fingerprints', 'Obey', 'branches', 'arrested', 'footprints'],
      correctAnswer: 'fingerprints',
    ),
    Question(
      text:
          '2. _________ Can tell you what type of shoes a thief was wearing. (Complete with: Obey, fingerprints, branches, arrested, footprints)',
      type: 'dropdown',
      options: ['fingerprints', 'Obey', 'branches', 'arrested', 'footprints'],
      correctAnswer: 'footprints',
    ),
    Question(
      text:
          '3. The Land Force, the Navy and, the Air Force are all _________ of the military. (Complete with: Obey, fingerprints, branches, arrested, footprints)',
      type: 'dropdown',
      options: ['fingerprints', 'Obey', 'branches', 'arrested', 'footprints'],
      correctAnswer: 'branches',
    ),
    Question(
      text:
          '4. The police officer _________ the criminal and put him in prison. (Complete with: Obey, fingerprints, branches, arrested, footprints)',
      type: 'dropdown',
      options: ['fingerprints', 'Obey', 'branches', 'arrested', 'footprints'],
      correctAnswer: 'arrested',
    ),
    Question(
      text:
          '5. Drivers must_________ the speed limit. (Complete with: Obey, fingerprints, branches, arrested, footprints)',
      type: 'dropdown',
      options: ['fingerprints', 'Obey', 'branches', 'arrested', 'footprints'],
      correctAnswer: 'Obey',
    ),
    Question(
      text:
          '6. Appt, appointment; co, _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'company',
    ),
    Question(
      text:
          '7. Computer, comp/18 years _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: '18 yrs',
    ),
    Question(
      text:
          '8. Occurred, happen/ Property _________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'stuff',
    ),
    Question(
      text:
          '9. Security camera. / metal_________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'detector',
    ),
    Question(
      text:
          '10. Branches, parts/ install_________ (Complete with correctly spelt word)',
      type: 'text_input',
      correctAnswer: 'put in',
    ),
  ],
  // الفصل الثالث: التنقل (Navigation)
  3: [
    // Textbook Passages
    Question(
      text:
          'A- Textbook Passages \n  \n 1. What (Who) is Samira Al Mahmoud? Where did she born?',
      type: 'text_input',
      correctAnswer: 'She is an interpreter. She was born in Britain',
    ),
    Question(
      text: '2. Samira\'s active language is_________',
      type: 'text_input',
      correctAnswer: 'Arabic',
    ),
    Question(
      text:
          '3. A good interpreter follows the news and is well-informed on many topics. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text:
          '4. Interpreters have to have a degree before they do an interpreting diploma. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text: '5. Interpreters must have three active languages. (true/false)',
      type: 'true_false',
      correctAnswer: false,
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. If you (find) a snake in your bed, what would you do? (correct)',
      type: 'text_input',
      correctAnswer: 'If you found a snake in your bed, what would you do?',
    ),
    Question(
      text:
          '2. I won\'t help Sharifa with her Maths if she (not lend) me camera. (correct)',
      type: 'text_input',
      correctAnswer:
          'I won\'t help Sharifa with her Maths if she doesn\'t lend me her camera',
    ),
    Question(
      text:
          '3. Unfortunately, I ate three bars of chocolate. That\'s why I felt sick. (Regret)',
      type: 'text_input',
      correctAnswer: 'I wish I hadn\'t eaten three bars of chocolate',
    ),
    Question(
      text:
          '4. How long have you been waiting for Faisal? He asked me_________ (Reported question)',
      type: 'text_input',
      correctAnswer: 'He asked me how long I had been waiting for Faisal',
    ),
    Question(
      text: '5. Define a teacher. (teach pupils)',
      type: 'text_input',
      correctAnswer: 'A teacher is someone who teaches pupils',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. Salwa works with the director of company. She writes all his letters and answers the telephones. She is his _________ (Complete with: technical terms, pilot, secretary, stressful, literal translation)',
      type: 'dropdown',
      options: [
        'technical terms',
        'pilot',
        'secretary',
        'stressful',
        'literal translation'
      ],
      correctAnswer: 'secretary',
    ),
    Question(
      text:
          '2. My work _________ .so I have to relax every day. (Complete with: technical terms, pilot, secretary, stressful, literal translation)',
      type: 'dropdown',
      options: [
        'technical terms',
        'pilot',
        'secretary',
        'stressful',
        'literal translation'
      ],
      correctAnswer: 'stressful',
    ),
    Question(
      text:
          '3. Captain Yousouf has been a _________ for ten years now. At the moment, he flies plans from Europe to the Gulf. (Complete with: technical terms, pilot, secretary, stressful, literal translation)',
      type: 'dropdown',
      options: [
        'technical terms',
        'pilot',
        'secretary',
        'stressful',
        'literal translation'
      ],
      correctAnswer: 'pilot',
    ),
    Question(
      text:
          '4. Avoid _________ when you work as an interpreter. (Complete with: technical terms, pilot, secretary, stressful, literal translation)',
      type: 'dropdown',
      options: [
        'technical terms',
        'pilot',
        'secretary',
        'stressful',
        'literal translation'
      ],
      correctAnswer: 'literal translation',
    ),
    Question(
      text:
          '5. _________ are used when we talk about technology. (Complete with: technical terms, pilot, secretary, stressful, literal translation)',
      type: 'dropdown',
      options: [
        'technical terms',
        'pilot',
        'secretary',
        'stressful',
        'literal translation'
      ],
      correctAnswer: 'technical terms',
    ),
  ],

  // الفصل الرابع: امتحان نصف السنة (MID EXAM)
  4: [
    // Unseen Passage
    Question(
      text:
          'Mid Exam \n \n Textbook Passages \n \n    Q1-A) Read the following passage carefully and answer (5) of the questions below(10 M) \n  When George Jones finished college, he became a clerk in a big company, hoping to advance to higher positions as time went on. He did his work reasonably well, but he was not very smart, so when the older employees retired from higher positions, it was never Jones who was promoted. After he had been with the company for fifteen years without ever being promoted, a smart young man, straight from college, came to work in the same department, and after a year, he was promoted above Jones. Jones was angry that he had not been promoted instead of this young man, so he went to his manager and said, I have had sixteen years experience on this job, yet a new man has been promoted over my head after having been here only one year. I am sorry, Jones," answered the manager patiently, "but you have not had sixteen years experience: You have had one year\'s experience sixteen times." \n \n   1. What was George\'s ambition?',
      type: 'text_input',
      correctAnswer: 'It is to advance to higher positions.',
    ),
    Question(
      text: '2. How did George feel when the young man was promoted?',
      type: 'text_input',
      correctAnswer: 'He was very angry.',
    ),
    Question(
      text: '3. Why did George go to see the manager?',
      type: 'text_input',
      correctAnswer:
          'To object on the manager\'s decision of promoting the new young man.',
    ),
    Question(
      text: '4. According to the manager, does George deserve to be promoted?',
      type: 'text_input',
      correctAnswer: 'No, he does not.',
    ),
    Question(
      text: '5. How was George\'s performance in the company?',
      type: 'text_input',
      correctAnswer: 'It was reasonably well.',
    ),
    Question(
      text: '6. Write a suitable title to the passage.',
      type: 'text_input',
      correctAnswer: 'Answers may vary.', // إجابة مفتوحة
    ),

    // Textbook Passages
    Question(
      text:
          '\n  \n B- Answer or complete (5) the following questions using information from your textbook. (10 M) \n  \n 1. Samira\'s active language is---------',
      type: 'text_input',
      correctAnswer: 'Arabic',
    ),
    Question(
      text: '2. Where did Mustafa find his mother?',
      type: 'text_input',
      correctAnswer: 'In her bedroom.',
    ),
    Question(
      text: '3. What is the radar detector?',
      type: 'text_input',
      correctAnswer: 'A machine that detects the radar guns',
    ),
    Question(
      text: '4. Why do some officers direct traffic?',
      type: 'text_input',
      correctAnswer: 'To make sure drivers can drive safely.',
    ),
    Question(
      text: '5. What is the most important quality of a good interpreter?',
      type: 'text_input',
      correctAnswer: 'Be calm under pressure.',
    ),
    Question(
      text:
          '6. When Zaid Tariq got back to the dry land he was taken--------(a. straight to his hotel / b. to get medical attention)',
      type: 'dropdown',
      options: ['straight to his hotel', 'to get medical attention'],
      correctAnswer: 'to get medical attention',
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n C- Grammar and Functions \n  \n 1. Salwa (eat) meat, but now she (be) a vegetarian. (Use the correct form of "used to" and the present or past simple)',
      type: 'text_input',
      correctAnswer: 'Salwa used to eat meat, but now she is a vegetarian.',
    ),
    Question(
      text:
          '2. If I (see) him yesterday, I would have told him your news. (Correct)',
      type: 'text_input',
      correctAnswer:
          'If I had seen him yesterday, I would have told him your news.',
    ),
    Question(
      text:
          '3........ an average of eight hours a night is about right. (Use imperative to give advice)',
      type: 'text_input',
      correctAnswer: 'Get enough sleep',
    ),
    Question(
      text: '4. Meet at 3:00 in departure lounge. (Suggestion)',
      type: 'text_input',
      correctAnswer: 'Let\'s meet at the departure lounge.',
    ),
    Question(
      text: '5. Define a tour guide. (Use: "show tourists around")',
      type: 'text_input',
      correctAnswer: 'A tour guide is someone who shows tourist around.',
    ),
    Question(
      text:
          '6. My mother asked somebody to paint the house. (Rewrite using the correct form of "get" or "make")',
      type: 'text_input',
      correctAnswer: 'My mother got the house painted.',
    ),
    Question(
      text:
          '7. Unfortunately, I missed my flight. That\'s why I won\'t get to Boston in time for the meeting. (Regret)',
      type: 'text_input',
      correctAnswer: 'If only I hadn\'t missed my flight.',
    ),
    Question(
      text:
          '8. How often do you clean your teeth? He asked me ..........(Reported question)',
      type: 'text_input',
      correctAnswer: 'He asked me how often I cleaned my teeth.',
    ),
    Question(
      text:
          'B Choose the correct word (Choose six only).(6M.) \n  \n 1_ When you get in a car, you (must, mustn\'t) put on your seat belt.',
      type: 'dropdown',
      options: ['must', 'mustn\'t'],
      correctAnswer: 'must',
    ),
    Question(
      text: '2_ She is not (interesting, interested) in fashion.',
      type: 'dropdown',
      options: ['interesting', 'interested'],
      correctAnswer: 'interested',
    ),
    Question(
      text:
          '3_ We left two hours early so we (should, shouldn\'t) miss the plane.',
      type: 'dropdown',
      options: ['should', 'shouldn\'t'],
      correctAnswer: 'shouldn\'t',
    ),
    Question(
      text: '4_ l \'ve got (little, few) work.',
      type: 'dropdown',
      options: ['little', 'few'],
      correctAnswer: 'little',
    ),
    Question(
      text: '5_ Sarah (carefully, careful) lifted the box.',
      type: 'text_input',
      correctAnswer: 'carefully',
    ),
    Question(
      text: '6_ The noise made him (looked, looking, look) outside.',
      type: 'dropdown',
      options: ['looked', 'looking', 'look'],
      correctAnswer: 'look',
    ),
    Question(
      text: '7_These shoes are good, can I (try on them, try them on)?',
      type: 'dropdown',
      options: ['try on them', 'try them on'],
      correctAnswer: 'try them on',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          'Q3 / vocabulary and Spelling (20M.) \n A/ Complete the sentence with suitable words from the box. (choose five only) (10 M) \n (canteen, lifeguard, fine , workshop, pain, disposed of) \n 1_ you must pay a………….... when you get a ticket.',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'fine',
    ),
    Question(
      text: '2_ Where exactly is the………………and how long have you had it?',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'pain',
    ),
    Question(
      text:
          '3_Sami was about to drown at the beach, luckily the…………... saw him and saved him.',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'lifeguard',
    ),
    Question(
      text:
          '4_The thief ………………..the stolen property when the police found him.',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'disposed of',
    ),
    Question(
      text: '5_I am going to register on a computer……………',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'workshop',
    ),
    Question(
      text: '6_ Let\'s have lunch in college………………..',
      type: 'dropdown',
      options: [
        'canteen',
        'lifeguard',
        'fine',
        'workshop',
        'pain',
        'disposed of'
      ],
      correctAnswer: 'canteen',
    ),
    Question(
      text:
          'B /Spelling (choose five only)(5M.) \n 1_ polite, impolite, dependent……………..',
      type: 'text_input',
      correctAnswer: 'independent',
    ),
    Question(
      text: '2_ company, co., appointment,………………….',
      type: 'text_input',
      correctAnswer: 'appt',
    ),
    Question(
      text: '3_join in the leg……………….',
      type: 'text_input',
      correctAnswer: 'knee,or ankle', // إجابة مفتوحة
    ),
    Question(
      text: '4_surprised, puzzled, civilian,……………….',
      type: 'text_input',
      correctAnswer: 'out of the military',
    ),
    Question(
      text: '5_beat beaten, steal,………………………..',
      type: 'text_input',
      correctAnswer: 'stolen',
    ),
    Question(
      text: '6_ metal=detector, x-ray,………………….',
      type: 'text_input',
      correctAnswer: 'machine',
    ),

    // Literature Focus
    Question(
      text:
          'Q4 literature focus ( choose five only)(10M.) \n 1_ Who was Katherine Mansfield?',
      type: 'text_input',
      correctAnswer: 'She was a famous modern writer.',
    ),
    Question(
      text: '2_ How does the story of The Canary end?',
      type: 'text_input',
      correctAnswer: 'Sadly, because the canary died.',
    ),
    Question(
      text: '3_ Why did Kathrine Mansfield become famous?',
      type: 'text_input',
      correctAnswer:
          'Because of her collection of short stories:The Bliss and The garden party.',
    ),
    Question(
      text: '4_ What were the people carried away by?',
      type: 'text_input',
      correctAnswer: 'The beautiful singing of the canary.',
    ),
    Question(
      text: '5_ What did the woman suffer from ?',
      type: 'text_input',
      correctAnswer: 'She suffered from loneliness.',
    ),
    Question(
      text: '6 What idea do people have of birds?',
      type: 'text_input',
      correctAnswer: 'They are heartless( have no heart) and cold creatures.',
    ),
  ],

  // الفصل الخامس: التعامل مع الشبكة (Networking)
  5: [
    // Textbook Passages
    Question(
      text:
          'A- Textbook Passages \n  \n 1. Where did Ann and her cousin go on holiday?',
      type: 'text_input',
      correctAnswer: 'They went to Kerkenna Islands in The Tunisian',
    ),
    Question(
      text: '2. What sports facilities were there at the hotel?',
      type: 'text_input',
      correctAnswer: 'swimming pool, tennis courts',
    ),
    Question(
      text:
          '3. The pressure of life will _________ a. cause health problems b. make us lose our jobs',
      type: 'dropdown',
      options: ['cause health problems', 'make us lose our jobs'],
      correctAnswer: 'cause health problems',
    ),
    Question(
      text: '4. Some people don\'t take holidays because they _________',
      type: 'text_input',
      correctAnswer: 'workaholics',
    ),
    Question(
      text:
          '5. Holidays are important for everyone, not just the businessman. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. Fadia didn\'t speak to me since her sister\'s wedding. (correct)',
      type: 'text_input',
      correctAnswer: 'Fadia hasn\'t spoken to me since her sister\'s wedding',
    ),
    Question(
      text:
          '2. The hotel has a swimming pool. (it is very big) (Relative clause)',
      type: 'text_input',
      correctAnswer: 'The hotel has a swimming pool which is very big',
    ),
    Question(
      text:
          '3. After we had spoken to the teacher, we (leave) the classroom. (correct)',
      type: 'text_input',
      correctAnswer:
          'After we had spoken to the teacher, we left the classroom',
    ),
    Question(
      text:
          '4. You meet a pilot. You ask: (How long / be a pilot?) (Write a question)',
      type: 'text_input',
      correctAnswer: 'How long have you been a pilot?',
    ),
    Question(
      text:
          '5. I (cook) for two hours. (Use present perfect simple or continuous)',
      type: 'text_input',
      correctAnswer: 'I have been cooking for two hours',
    ),
    Question(
      text:
          '6. Babylon city, _________ people like to go to sightseeing, is beautiful place. (which/that/where)',
      type: 'dropdown',
      options: ['which', 'that', 'where'],
      correctAnswer: 'where',
    ),
    Question(
      text:
          '7. I _________ to China yet, but I would like to one day. (didn\'t go/haven\'t been/haven\'t gone)',
      type: 'dropdown',
      options: ['didn\'t go', 'haven\'t been', 'haven\'t gone'],
      correctAnswer: 'haven\'t been',
    ),
    Question(
      text:
          '8. A thief got into their house because they _________ the door properly. (haven\'t locked/haven\'t been locking/hadn\'t locked)',
      type: 'dropdown',
      options: ['haven\'t locked', 'haven\'t been locking', 'hadn\'t locked'],
      correctAnswer: 'hadn\'t locked',
    ),
    Question(
      text:
          '9. Souhaib, _________ brother lives in California, is planning a trip to the USA soon. (which/whose/who\'s)',
      type: 'dropdown',
      options: ['which', 'whose', 'who\'s'],
      correctAnswer: 'whose',
    ),
    Question(
      text:
          '10. She\'s been talking on the phone_________ the last 20 minutes. (since/for/with)',
      type: 'dropdown',
      options: ['since', 'for', 'with'],
      correctAnswer: 'for',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. Our package deal included_________ in the evenings (Complete with: entertainment, spectacular, expectations, overlooked, board)',
      type: 'dropdown',
      options: [
        'entertainment',
        'spectacular',
        'expectations',
        'overlooked',
        'board'
      ],
      correctAnswer: 'entertainment',
    ),
    Question(
      text:
          '2. To cross the river we had to _________ ferry. (Complete with: entertainment, spectacular, expectations, overlooked, board)',
      type: 'dropdown',
      options: [
        'entertainment',
        'spectacular',
        'expectations',
        'overlooked',
        'board'
      ],
      correctAnswer: 'board',
    ),
    Question(
      text:
          '3. We were delighted that our hotel_________ the beach. (Complete with: entertainment, spectacular, expectations, overlooked, board)',
      type: 'dropdown',
      options: [
        'entertainment',
        'spectacular',
        'expectations',
        'overlooked',
        'board'
      ],
      correctAnswer: 'overlooked',
    ),
    Question(
      text:
          '4. The view from the top of the hill is quite_________ (Complete with: entertainment, spectacular, expectations, overlooked, board)',
      type: 'dropdown',
      options: [
        'entertainment',
        'spectacular',
        'expectations',
        'overlooked',
        'board'
      ],
      correctAnswer: 'spectacular',
    ),
    Question(
      text:
          '5. The holiday completely lived up to my _________ (Complete with: entertainment, spectacular, expectations, overlooked, board)',
      type: 'dropdown',
      options: [
        'entertainment',
        'spectacular',
        'expectations',
        'overlooked',
        'board'
      ],
      correctAnswer: 'expectations',
    ),
  ],

  // الفصل السادس: قواعد البيانات المحلية
  6: [
    // Textbook Passages
    Question(
      text: 'A- Textbook Passages \n  \n 1. How can we invest our money?',
      type: 'text_input',
      correctAnswer:
          'In stocks and shares, in saving accounts, in pension plans and in property',
    ),
    Question(
      text: '2. Why should people save money for future?',
      type: 'text_input',
      correctAnswer:
          'People should save money for the future so they can enjoy a good standard of living',
    ),
    Question(
      text:
          '3. Bankers need only to know about financially subjects. (true/false)',
      type: 'true_false',
      correctAnswer: false,
    ),
    Question(
      text: '4. One of the banker\'s skills is to be good at _________',
      type: 'text_input',
      correctAnswer: 'Maths',
    ),
    Question(
      text: '5. What is the most popular investment in the UK at the moment?',
      type: 'text_input',
      correctAnswer: 'Investment in property',
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. was The yesterday bank robbed. (Unscramble the words)',
      type: 'text_input',
      correctAnswer: 'The bank was robbed yesterday',
    ),
    Question(
      text: '2. Somebody will pay the bill tomorrow. (passive)',
      type: 'text_input',
      correctAnswer: 'The bill will be paid tomorrow',
    ),
    Question(
      text:
          '3. My ATM card (steal) yesterday, so I have to get a new one. (passive)',
      type: 'text_input',
      correctAnswer:
          'My ATM card was stolen yesterday, so I have to get a new one',
    ),
    Question(
      text: '4. Somebody teaches History every day. (passive)',
      type: 'text_input',
      correctAnswer: 'History is taught every day',
    ),
    Question(
      text: '5. Somebody was opening the gates when we arrived. (passive)',
      type: 'text_input',
      correctAnswer: 'The gates were being opened when we arrived',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. A _________ account comes with a cheque book. (Complete with: balance, current, withdraw, valid, statement)',
      type: 'dropdown',
      options: ['balance', 'current', 'withdraw', 'valid', 'statement'],
      correctAnswer: 'current',
    ),
    Question(
      text:
          '2. The minimum _________ is 1,000 Iraqi dinars. (Complete with: balance, current, withdraw, valid, statement)',
      type: 'dropdown',
      options: ['balance', 'current', 'withdraw', 'valid', 'statement'],
      correctAnswer: 'balance',
    ),
    Question(
      text:
          '3. I\'m afraid your card is no longer _________ . It expired a week ago. (Complete with: balance, current, withdraw, valid, statement)',
      type: 'dropdown',
      options: ['balance', 'current', 'withdraw', 'valid', 'statement'],
      correctAnswer: 'valid',
    ),
    Question(
      text:
          '4. This bank _________ shows I have a lot of money in my account. (Complete with: balance, current, withdraw, valid, statement)',
      type: 'dropdown',
      options: ['balance', 'current', 'withdraw', 'valid', 'statement'],
      correctAnswer: 'statement',
    ),
    Question(
      text:
          '5. There must be a mistake. I didn\'t make this _________ last week. (Complete with: balance, current, withdraw, valid, statement)',
      type: 'dropdown',
      options: ['balance', 'current', 'withdraw', 'valid', 'statement'],
      correctAnswer: 'withdrawal',
    ),
  ],

  // الفصل السابع: الرسوم المتحركة (Animations)
  7: [
    // Textbook Passages
    Question(
      text:
          'A- Textbook Passages \n  \n 1. Why are spreadsheets used a lot in businesses?',
      type: 'text_input',
      correctAnswer: 'Because they can show information in table form',
    ),
    Question(
      text: '2. Give two reasons for improving computer skills.',
      type: 'text_input',
      correctAnswer: 'To improve job prospects and to help find a new career',
    ),
    Question(
      text:
          '3. At library the writer can learn how to apply for jobs. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text: '4. The writer can borrow DVDs from the library. (true/false)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text: '5. The writer wants to find a job in his country. (true/false)',
      type: 'true_false',
      correctAnswer: false,
    ),

    // Grammar and Functions
    Question(
      text:
          '\n  \n B- Grammar and Functions \n  \n 1. He is going to a painting class this evening. (Future in the past)',
      type: 'text_input',
      correctAnswer: 'He was going to a painting class that evening',
    ),
    Question(
      text: '2. I know the classes start in the summer. (Future in the past)',
      type: 'text_input',
      correctAnswer: 'I knew the classes started in the summer',
    ),
    Question(
      text:
          '3. Dana is going to _________ at the hospital when she has more time. (Volunteer/volunteers)',
      type: 'dropdown',
      options: ['Volunteer', 'volunteers'],
      correctAnswer: 'Volunteer',
    ),
    Question(
      text:
          '4. Volunteer training _________ on the first of the month. (will be beginning/begins)',
      type: 'dropdown',
      options: ['will be beginning', 'begins'],
      correctAnswer: 'begins',
    ),
    Question(
      text: '5. I think she _________ the work. (will like/will be liking)',
      type: 'dropdown',
      options: ['will like', 'will be liking'],
      correctAnswer: 'will like',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          '\n  \n C- Vocabulary and spelling \n  \n 1. I\'d like to train as a _________ because I love books and librarian. (Complete with: enroll, medical, supervise, conference, librarian)',
      type: 'dropdown',
      options: ['enroll', 'medical', 'supervise', 'conference', 'librarian'],
      correctAnswer: 'librarian',
    ),
    Question(
      text:
          '2. She\'s a _________ student. she should qualify as a doctor in two years\' time. (Complete with: enroll, medical, supervise, conference, librarian)',
      type: 'dropdown',
      options: ['enroll', 'medical', 'supervise', 'conference', 'librarian'],
      correctAnswer: 'medical',
    ),
    Question(
      text:
          '3. Next year I plan to _________ on a course to improve my English. (Complete with: enroll, medical, supervise, conference, librarian)',
      type: 'dropdown',
      options: ['enroll', 'medical', 'supervise', 'conference', 'librarian'],
      correctAnswer: 'enroll',
    ),
    Question(
      text:
          '4. If you are manager, you have to _________ other employees. (Complete with: enroll, medical, supervise, conference, librarian)',
      type: 'dropdown',
      options: ['enroll', 'medical', 'supervise', 'conference', 'librarian'],
      correctAnswer: 'supervise',
    ),
    Question(
      text:
          '5. Last summer my father, who is a scientist, attended a big _________ (Complete with: enroll, medical, supervise, conference, librarian)',
      type: 'dropdown',
      options: ['enroll', 'medical', 'supervise', 'conference', 'librarian'],
      correctAnswer: 'conference',
    ),
  ],

  // الفصل الثامن: الامتحان النهائي (FINAL EXAM)
  8: [
    // Reading Comprehension
    Question(
      text:
          'Final Exam \n  \n Q1/A) Read this text carefully then answer (5) of the questions that follow. (10 M) \n \n  One sunny morning, an old woman was driving her small silver car through the busy streets of the city. She followed the traffic rules carefully. Suddenly, a police officer stopped her. He looked surprised and said "Excuse me, madam. You seem quite old to be driving alone. Are you sure you\'re able to drive safely at your age?" The woman smiled politely and replied, "Officer, I have been driving over fifty years. I\'ve never had an accident. My eyesight is still very good." The officer seemed unsure and asked, "Can you prove that your eyesight is still good?" Without hesitation, the woman opened her handbag and took out a small sewing needle and a piece of thread. Calmly and quickly, she put the thread through the small hole of the needle. She looked at the officer and said, "If I can do this, then I can see the road very well." The officer was surprised and laughed. "That\'s amazing!" he said. "Your eyesight is better than mine!" He smiled respectfully and said "That\'s very admirable, madam. Have a safe drive." The woman thanked him, smiled and drove away confidently. She felt proud that she could prove herself and she hoped people would learn that age does not always mean weakness or inability. \n \n  1. Why did the police officer stop the old woman?',
      type: 'text_input',
      correctAnswer: 'Because she seemed quite old to be driving alone.',
    ),
    Question(
      text: '2. The woman had been driving for only five years. (True / False)',
      type: 'true_false',
      correctAnswer: false,
    ),
    Question(
      text: '3. How did the woman prove her eyesight was good?',
      type: 'text_input',
      correctAnswer:
          'She put the thread through the small hole of the needle calmly and quickly',
    ),
    Question(
      text: '4. Where was the woman driving?',
      type: 'text_input',
      correctAnswer: 'through the busy streets of the city',
    ),
    Question(
      text:
          '5. What lesson can we learn from the story? (a. Don\'t judge people by age. b. Police officers are always right.)',
      type: 'dropdown',
      options: [
        'Don\'t judge people by age.',
        'Police officers are always right.'
      ],
      correctAnswer: 'Don\'t judge people by age.',
    ),
    Question(
      text: '6. Give the passage a suitable title.',
      type: 'text_input',
      correctAnswer: 'The Old Woman and the Police Officer.',
    ),

    // Textbook Passages
    Question(
      text:
          'B / Answer or complete (Five) of the following sentences using information from your text book: (10 M) \n \n 1. The banker has to assess new business ideas. (True / False)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text:
          '2. The library has an information about languages test. ---------------',
      type: 'text_input',
      correctAnswer:
          'It is also let you to borrow DVDs with language learning games and exercises.',
    ),
    Question(
      text: '3. Why do people have to follow law?',
      type: 'text_input',
      correctAnswer: 'so that we can all live together safely.',
    ),
    Question(
      text:
          '4. Why did Samira not translate the Arabic phrase "Akl il-inab habba habba" literally into English? \n \n a. She didn\'t know how to say it. \n b. It wouldn\'t have been clear to English listeners.',
      type: 'dropdown',
      options: ['A', 'B'],
      correctAnswer: 'It wouldn\'t have been clear to English listeners.',
    ),
    Question(
      text: '5. What do the diabetics have to do every day?',
      type: 'text_input',
      correctAnswer: 'They have to take an injection of insulin.',
    ),
    Question(
      text:
          '6. If we don\'t take breaks, the pressure of life can affect both our ----------and------------health.',
      type: 'text_input',
      correctAnswer: 'Physical, mental',
    ),

    // Grammar and Functions
    Question(
      text:
          'Q2/A) Re-write the following sentences, follow the instructions between brackets. (Choose 10) (20 M) \n \n 1. This is a new computer, so I think it is faster than the other one. (Expectation)',
      type: 'text_input',
      correctAnswer:
          'This is a new computer, so it should be faster than the other one.',
    ),
    Question(
      text:
          '2. I (clean) my room and I (find) 30 under my bed. (Put one verb in the past continuous and one in the past simple)',
      type: 'text_input',
      correctAnswer: 'I was cleaning my room and I found 30 under my bed.',
    ),
    Question(
      text: '3. Have you finished your homework? (Reported question)',
      type: 'text_input',
      correctAnswer: 'She asked me if I had finished my homework.',
    ),
    Question(
      text:
          '4. The leaves fell because of the wind. (Re-write the sentence with the correct form of "Make") \n The wind……………..',
      type: 'text_input',
      correctAnswer: 'The wind made the leaves fall.',
    ),
    Question(
      text:
          '5. If it (be) sunny tomorrow, we will go for a picnic. (Correct the form of the verb)',
      type: 'text_input',
      correctAnswer: 'If it is sunny tomorrow, we will go for a picnic.',
    ),
    Question(
      text:
          '6. You decided not to go to the park with your friends. Now you regret it. (Regret: use "If only")',
      type: 'text_input',
      correctAnswer: 'If only I had gone to the park with my friends.',
    ),
    Question(
      text:
          '7. (Next/ being/ are / week/ The/ replaced/ windows) (Put the words in brackets into a passive sentence)',
      type: 'text_input',
      correctAnswer: 'The windows are being replaced next week.',
    ),
    Question(
      text:
          '8. The Tigris hotel has a fabulous pool. (The pool opened two months ago) (Use the correct relative pronoun to make one sentence)',
      type: 'text_input',
      correctAnswer:
          'The Tigris Hotel has a fabulous pool which opened two months ago.',
    ),
    Question(
      text: '9. I will arrive on time \n "I knew I…………... (Future in the past)',
      type: 'text_input',
      correctAnswer: 'would arrive on time',
    ),
    Question(
      text:
          '10. She (not like) coffee, but now she (drink) it every day. (Use the correct form of "used to" and the present or past simple)',
      type: 'text_input',
      correctAnswer:
          'She didn\'t use to like coffee, but now she drinks it every day',
    ),
    Question(
      text:
          '11. You meet a pilot. (Ask: how long / be a pilot?) (Write a question using the words in brackets; use the present perfect simple or present perfect continuous)',
      type: 'text_input',
      correctAnswer: 'How long have you been a pilot?',
    ),
    Question(
      text:
          '12……….... An average of eight hours at night is about right. (Use an imperative to give advice)',
      type: 'text_input',
      correctAnswer: 'Get enough sleep',
    ),
    Question(
      text:
          'B/ Choose the correct word between brackets: (5 only) (10 M) \n \n 1. He has had that car (since / for) a long time.',
      type: 'dropdown',
      options: ['since', 'for'],
      correctAnswer: 'for',
    ),
    Question(
      text: '2. We need a (few / little) water for the plants.',
      type: 'dropdown',
      options: ['few', 'little'],
      correctAnswer: 'little',
    ),
    Question(
      text: '3. I like this jacket. Can I (try on it / try it on)?',
      type: 'dropdown',
      options: ['try on it', 'try it on'],
      correctAnswer: 'try it on',
    ),
    Question(
      text:
          '4. When you get in a car, you (needn\'t / need to) put on your seat belt.',
      type: 'dropdown',
      options: ['needn\'t', 'need to'],
      correctAnswer: 'need to',
    ),
    Question(
      text: '5. Let\'s (take / taking) a taxi to the airport.',
      type: 'dropdown',
      options: ['take', 'taking'],
      correctAnswer: 'take',
    ),
    Question(
      text: '6.It was the most (frightened / frightening) day of my life.',
      type: 'dropdown',
      options: ['frightened', 'frightening'],
      correctAnswer: 'frightening',
    ),

    // Vocabulary and Spelling
    Question(
      text:
          'Q3/A) Complete each sentence with the suitable word from the box: (10 M) \n \n (lifeguard, instilled, dizzy, qualifications, plumber, renewable) \n \n 1. She went pale and felt--------------during the lesson.',
      type: 'dropdown',
      options: [
        'lifeguard',
        'instilled',
        'dizzy',
        'qualifications',
        'plumber',
        'renewable'
      ],
      correctAnswer: 'dizzy',
    ),
    Question(
      text: '2. Water, wind and sunlight are all examples of--------------',
      type: 'dropdown',
      options: [
        'lifeguard',
        'instilled',
        'dizzy',
        'qualifications',
        'plumber',
        'renewable'
      ],
      correctAnswer: 'renewable',
    ),
    Question(
      text:
          '3. A------------is someone who is responsible for the safety of swimmers.',
      type: 'dropdown',
      options: [
        'lifeguard',
        'instilled',
        'dizzy',
        'qualifications',
        'plumber',
        'renewable'
      ],
      correctAnswer: 'lifeguard',
    ),
    Question(
      text:
          '4. His parents----------------in him the value of saving before spending.',
      type: 'dropdown',
      options: [
        'lifeguard',
        'instilled',
        'dizzy',
        'qualifications',
        'plumber',
        'renewable'
      ],
      correctAnswer: 'instilled',
    ),
    Question(
      text:
          '5. I can\'t get that job because I don\'t have the right-----------.',
      type: 'dropdown',
      options: [
        'lifeguard',
        'instilled',
        'dizzy',
        'qualifications',
        'plumber',
        'renewable'
      ],
      correctAnswer: 'qualifications',
    ),

// Matching question from FINAL EXAM (Reversed)
    Question(
      text:
          'B/ Match the words and phrases in List A with their definitions in List B. \n \n 1. a. activity in your bank account.',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'transaction',
    ),
    Question(
      text: '2. b. a lot (of)',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'considerable',
    ),
    Question(
      text: '3. c. working quickly and well',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'efficient',
    ),
    Question(
      text:
          '4. d. the process of damaging the air, water or land with chemicals.',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'pollution',
    ),
    Question(
      text: '5. e. if you lose this, you can\'t get on an airplane.',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'boarding card',
    ),
    Question(
      text: '6. f. something which is wonderful to look at.',
      type: 'dropdown',
      options: [
        'considerable',
        'spectacular',
        'transaction',
        'boarding card',
        'efficient',
        'pollution'
      ],
      correctAnswer: 'spectacular',
    ),

    Question(
      text:
          'C/ Write the missing words. (Choose 5 only) (5 M) \n \n 1. frequent; freq; experience;--------------',
      type: 'text_input',
      correctAnswer: 'exp.',
    ),
    Question(
      text: '2. usual; unusual; legal;---------------------',
      type: 'text_input',
      correctAnswer: 'illegal',
    ),
    Question(
      text: '3. joint in the arm;---------------------',
      type: 'text_input',
      correctAnswer: 'Wrist, shoulder, elbow',
    ),
    Question(
      text: '4. do; done; see;-------------------',
      type: 'text_input',
      correctAnswer: 'Seen',
    ),
    Question(
      text: '5. the opposite of deep; -----------------------',
      type: 'text_input',
      correctAnswer: 'Shallow',
    ),
    Question(
      text: '6. careful; carefully; peaceful;--------------------',
      type: 'text_input',
      correctAnswer: 'peacefully',
    ),

    // Literature Focus
    Question(
      text:
          'Q4) Answer or complete (5) of the following questions: (10 M) \n \n 1. What were the people carried away by?',
      type: 'text_input',
      correctAnswer: 'By the beautiful singing of the canary.',
    ),
    Question(
      text: '2. The woman bought the canary from----------',
      type: 'text_input',
      correctAnswer: 'a The Chinaman.',
    ),
    Question(
      text: '3. How did the canary greet his owner in the morning?',
      type: 'text_input',
      correctAnswer: 'He greeted her with a drowsy little note.',
    ),
    Question(
      text:
          '4. Katherine was the-------------of five children in the family. (fourth / third)',
      type: 'dropdown',
      options: ['fourth', 'third'],
      correctAnswer: 'third',
    ),
    Question(
      text: '5. Why did Katherine move to London in 1903?',
      type: 'text_input',
      correctAnswer: 'To study music at Queen\'s College.',
    ),
    Question(
      text: '6. What was the canary to the woman?',
      type: 'text_input',
      correctAnswer: 'A perfect company.',
    ),
  ],

  // الفصل التاسع: الاختبارات (Testing)
  9: [
    Question(
      text: '1-The woman bought the canary from----------',
      type: 'text_input',
      correctAnswer: 'Chinaman',
    ),
    Question(
      text: '2-Katherine was the-------------of five children in the family.',
      type: 'text_input',
      correctAnswer: 'third',
    ),
    Question(
      text: '3-How does the story of (canary) end?',
      type: 'text_input',
      correctAnswer: 'It ends with the died of canary.',
    ),
    Question(
      text:
          '4- People have the idea that birds are heartless and cold little creatures. (True / False)',
      type: 'true_false',
      correctAnswer: true,
    ),
    Question(
      text: '5- When did Katherine die?',
      type: 'text_input',
      correctAnswer: 'She died in January in 1923.',
    ),
    Question(
      text: '6-Where and when was she born?',
      type: 'text_input',
      correctAnswer: 'She was born in 1888 in New Zealand.',
    ),
  ],
};

// هيكل البيانات للفيديوهات لكل درس وفصل
final Map<int, Map<int, List<String>>> lessonsVideos = {
  // الفصل الأول

  1: {
    1: ['EmLtn_fSNN0', 'THQ1igupe08', 'vR46Ph_JpqM', 'p2nTxrGaLlg'],
    2: [
      'EmLtn_fSNN0',
      'Rcdm6SUfCZE',
      'sZhRi3mB0nY',
      'BETOA1dWM4Y',
      'Hb_EmozBelI'
    ],
    3: [
      'EmLtn_fSNN0',
      'fFfg6azsxoM',
      'iyqwrcLoQuI',
      'dZzMYAiF3EQ',
      'gDjxwHADEnM',
      '_q5Zoy1z0M0',
      'gYEqHW2ZJIs'
    ],
    4: [
      'EmLtn_fSNN0',
      'akYcILKDqog',
      'RD6suvWfcCI',
      'j0e6fSYHZWo',
      'QDZNy1IonMM',
      '3T7jQ0dcA_A'
    ],
    5: [
      'EmLtn_fSNN0',
      '2Uej5-rK1Pw',
      'R5YC2qvyn1s',
      'd4CBrGt7cQs',
      'gmYRBxh-wNg',
      'NPn0WpUWLKw'
    ],
    6: [
      'EmLtn_fSNN0',
      'M5isdSRiTaI',
      'HmVEYpNYhtQ',
      'wnNpV08TBN8',
      'yQplTViwmbM'
    ],
    7: ['EmLtn_fSNN0', '1-0ZZPxge8o', 'x3hsFDyVUWk'],
    8: ['EmLtn_fSNN0', '2GYyaWQABMk'],
    9: ['EmLtn_fSNN0', 'vDfAOr2bHJo', '-mLQQiRkWOk'],
  },

  2: {
    1: ['EmLtn_fSNN0', 'U8znwJ-Em_Y', '2uq1c71YqRI'],
    2: [
      'EmLtn_fSNN0',
      'TC03KzNSzFU',
      '05C4yeUgJsQ',
      '6DytMBkeaGw',
      'RFYTTq1D7AM',
      'lJS1lP-8Jas'
    ],
    3: [
      'EmLtn_fSNN0',
      'qXxqEjPzc_A',
      '3jpjbm1iasc',
      'wAIsQzAVQSA',
      'oGx-ZjT9Pgg',
      'qUCRHr3PP8c',
      'ooxR8iZ3j5U'
    ],
    4: [
      'EmLtn_fSNN0',
      'zlN9dncjWJA',
      'zhlQQ6Kp1ds',
      'n6reVZqyt7E',
      '1KaW7dT3MBk'
    ],
    5: ['EmLtn_fSNN0', '7nP6LthR45k', 'Mgt5kuOoFUo', 'D4wP0EL7_Ek'],
    6: ['EmLtn_fSNN0', '54sB1tq5VVs', 'OdTbq1cbZAE', 'V0H0QKpfeBY'],
    7: ['EmLtn_fSNN0', 'HYFoDUvj2tI'],
    8: ['EmLtn_fSNN0', '2D2oJ1GVI0M'],
    9: ['EmLtn_fSNN0', 'lzh6YSSjzyo', '6KrO6Nw7OQ0'],
    10: ['EmLtn_fSNN0', '2w9Dp3ynElA', 'H0gNu0J1YWM', 'K_BDn_EjzEE'],
  },
  3: {
    1: ['EmLtn_fSNN0', 'Ow-w6He4oGQ', 'v1lZFWUw0bI', '1lhf2l5IYww'],
    2: ['EmLtn_fSNN0', '1DuENRg0KnE', 'EnfLO_sZs5o'],
    3: ['EmLtn_fSNN0', '-D0sn8_3UzY', 'X8zlbN3wbLQ', '7-hYe--xSgA'],
    4: ['EmLtn_fSNN0', 'MWL2DBxVLCw', 'bz5koeRZZ4g', '5DO5GZVJ0Cc'],
    5: ['EmLtn_fSNN0', '1HARHfFjcrk'],
    6: ['EmLtn_fSNN0', 'XUGtWNum0JY', '4DepUds9a8Y'],
    7: ['EmLtn_fSNN0', 'DR_YHRAx1FQ'],
    8: ['EmLtn_fSNN0', '1-7E1fDMPnY'],
    9: [
      'EmLtn_fSNN0',
      'KdYd9D2CNlY',
      'b0oUKiqZjYs',
      '056cvXx1Hks',
      '9VcCyBslqeE',
      'Ks0KtC-QnXw',
      'TW_zVLfVq-Q'
    ],
    10: [
      'EmLtn_fSNN0',
      'SusLXkpifhM',
      'LsszF-rHxzc',
      'FTqjxEFCPVk',
      'xvY9bRHX0sk',
      'p07aH3e2JXU'
    ],
  },
  4: {
    1: ['EmLtn_fSNN0', 'BzNN6s7Fqng', 'VWyfD90B_dw'],
    2: [
      'EmLtn_fSNN0',
      'Ux-PM2oNX7g',
      'TWejm45t9qo',
      'O6KuPSCuus4',
      'uDWGHiumhhA',
      'W-ph7yjkksU',
      'IGWmAAJktlg'
    ],
  },
  5: {
    1: ['EmLtn_fSNN0', 'YWkuVyP1svU', 'sGuzMa7oOmI'],
    2: ['EmLtn_fSNN0', 't6xqEFSIgEU', 'RGvJs7SuVw4', 'XYhTjhvlcUM'],
    3: [
      'EmLtn_fSNN0',
      'REbArpgCLrQ',
      'UvQSphaNmOE',
      'u-3LHaLEPDE',
      'Hg1JAoHBkfk',
      'ehplXzzbzjM',
      'HOld_UHwnZM',
      '0nX5X1ciVcA'
    ],
    4: ['EmLtn_fSNN0', 'Al1HQc38jo4', '6xgppuA1fNk', 'ymVpkUlfLKg'],
    5: ['EmLtn_fSNN0', '6IW8WmfgBZo', 'lzn2xpH4qA4', 'YVFWO7gIXdE'],
    6: ['EmLtn_fSNN0', 'bYnYQiDVpIs', '6n1kq85f8dA', 'tqTRMk_eFKc'],
    7: [
      'EmLtn_fSNN0',
      'jlxFjXcfG6M',
      'VZPFF0vGnqg',
      'fYTgVEHdyp0',
      '-suhdQcBTFI'
    ],
    8: ['EmLtn_fSNN0', 'LZT43IHzLV4', 'XvpQdSniY9Y'],
    9: [
      'EmLtn_fSNN0',
      'INsI8xULz_w',
      'bKovECoURiw',
      'iEgFx0YwOzk',
      'ija9WEY5UDA',
      'y2lE3Dx4EzU',
      'pCOuYa7DNa0',
      'iH9QzXwlZXo',
      'V2QRvvEBwoU',
      'SgHEtSFklYE'
    ],
    10: [
      'EmLtn_fSNN0',
      'qBZ0ThvyM1g',
      'J_FD2OpryXY',
      'OeUZR3xLHDE',
      'h2chjB1jJHw'
    ],
  },
  6: {
    1: ['EmLtn_fSNN0', 'VShlDqM_Iac'],
    2: [
      'EmLtn_fSNN0',
      '4JbAfREvOnk',
      'Mw44Jghs4x8',
      '1Tb5ZmzGe-s',
      '89_V5ubWKpA',
      'a40SGpTx9xU'
    ],
    3: ['EmLtn_fSNN0', 'lyDGcD9yOZA', '96LZY3DR9pA'],
    4: ['EmLtn_fSNN0', 'rrHzcqEyu_k'],
    5: ['EmLtn_fSNN0', 'Ge1vlHbvm5w', 'NzoAar0Rwnc'],
    6: ['EmLtn_fSNN0', 'W94sjPKidHo'],
    7: ['EmLtn_fSNN0', '754Za9ZceW8'],
    8: ['EmLtn_fSNN0', 'WJDXLoNu5XU', 'A-aKTCDkok8'],
    9: [
      'EmLtn_fSNN0',
      'b261lDDMBSI',
      'aZOwTAJDv5Y',
      '4PA6yXuNXo8',
      'PP5wCLZfzg4',
      's5fn-YdzZlA',
      'Kd1yrwjutAI',
      '0AeXIzkSByM'
    ],
    10: ['EmLtn_fSNN0', 'LOHpaJaEML0', 'sWQ6ifYl__Q', 'X-ktM83cEYY'],
  },
  7: {
    1: ['EmLtn_fSNN0', 'NAzY7HYfnV0', 'i21hH6yYkAc', 'sG75tonKqXM'],
    2: ['EmLtn_fSNN0', 'VTy_W_n7yr0'],
    3: ['EmLtn_fSNN0', 'IWdNbOKnTjM', 'EWzKOna9KhM'],
    4: ['EmLtn_fSNN0', 'XaRNsjusswM', 'zC0U0EY2O50'],
    5: ['EmLtn_fSNN0', 'qgd3kXZB9dQ', 'FAsivgqwbnU'],
    6: ['EmLtn_fSNN0', 'jXtPMCg_0JI'],
    7: ['EmLtn_fSNN0', 'dsghxgjlKk0'],
    8: ['EmLtn_fSNN0', 'Mh_IzhtxTBY'],
    9: [
      'EmLtn_fSNN0',
      'oqa9TFBxqSo',
      'cPURmK3zqNY',
      '-is6evyN8WE',
      '_tQtMY-LjUg',
      'ltKRgsQXvRc',
      's1S98kY5PCQ'
    ],
    10: ['EmLtn_fSNN0', '3xx3frcEyD4', '4xWqkA8eZLA', 'oRMaw7alPwE'],
  },
  8: {
    1: ['EmLtn_fSNN0', 'ycFA6BTP6bU'],
    2: ['EmLtn_fSNN0', 'M5woSRC_NiI'],
    3: ['EmLtn_fSNN0', '2nEus1c4GXo'],
    4: [
      'EmLtn_fSNN0',
      'sHqgKCdYSdw',
      'vzOGgLkiRCk',
      'qjCRc_CHXNg',
      'oiMIg4f1HuE',
      'mqSS-jiU3CE',
      '0OWAdpZ1Wlk',
      'Qk91cIr5Jbg'
    ],
  },
  9: {
    2: ['EmLtn_fSNN0', 'dhFhjWDNXhI'],
    3: ['EmLtn_fSNN0', 'rQxVKBGEpH8'],
  },
};

// وظائف حفظ وتحميل البيانات باستخدام SharedPreferences
const _chapterKey = 'last_chapter';
const _lessonKey = 'last_lesson';
const _videoIndexKey = 'last_video_index';
const _hintShownKey = 'hint_shown';

Future<void> saveLastLesson(int chapter, int lesson, int videoIndex) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_chapterKey, chapter);
  await prefs.setInt(_lessonKey, lesson);
  await prefs.setInt(_videoIndexKey, videoIndex);
}

Future<Map<String, int?>> getLastLesson() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'chapter': prefs.getInt(_chapterKey),
    'lesson': prefs.getInt(_lessonKey),
    'videoIndex': prefs.getInt(_videoIndexKey),
  };
}

Future<bool> getHintShown() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_hintShownKey) ?? false;
}

Future<void> setHintShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hintShownKey, true);
}

Future<void> saveChapterScore(int chapter, int score) async {
  final prefs = await SharedPreferences.getInstance();
  final currentBest = prefs.getInt('chapter${chapter}_best_score') ?? 0;

  // حفظ آخر نتيجة
  await prefs.setInt('chapter${chapter}_score', score);

  // حفظ أفضل نتيجة إذا كانت الجديدة أفضل
  if (score > currentBest) {
    await prefs.setInt('chapter${chapter}_best_score', score);
  }
}

Future<int> getChapterScore(int chapter) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('chapter${chapter}_score') ?? 0;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  // طلب صلاحيات الإشعارات من المستخدم
  await FirebaseMessaging.instance.requestPermission();

  // ضبط اتجاه التطبيق
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.cyanAccent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.cyanAccent,
              width: 2,
            ),
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.cyanAccent),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent.withOpacity(0.8),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _robotController;
  late Animation<double> _robotAnimation;
  late AnimationController _gradientController;
  late AnimationController _textAnimationController;
  bool _isLoading = false;

  // ألوان متدرجة ديناميكية
  final List<Color> _gradientColors = [
    const Color(0xFF0F2027),
    const Color(0xFF203A43),
    const Color(0xFF2C5364),
    const Color(0xFF0F2027),
  ];

  @override
  void initState() {
    super.initState();

    // تحريك الروبوت
    _robotController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _robotAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _robotController, curve: Curves.easeInOut),
    );

    // تحريك التدرج اللوني
    _gradientController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    // تحريك النص
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // تسجيل فتح التطبيق
    _recordAppOpening();
    FirebaseMessaging.instance.subscribeToTopic('all_users');
  }

  void _recordAppOpening() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/last_open_timestamp')
          .set(now);
      print(
          'تم تسجيل وقت فتح التطبيق في Firebase للمستخدم: ${user.uid} في الوقت: $now');
    } else {
      print('لا يوجد مستخدم مسجل الدخول، لم يتم تسجيل وقت فتح التطبيق.');
    }
  }

  void _startRegistration() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PhoneRegistrationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _robotController.dispose();
    _gradientController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final colorValue = _gradientController.value;
          final colorIndex = (colorValue * _gradientColors.length).floor() %
              _gradientColors.length;
          final nextColorIndex = (colorIndex + 1) % _gradientColors.length;
          final colorTweenValue =
              (colorValue * _gradientColors.length) - colorIndex;

          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.8,
                colors: [
                  Color.lerp(_gradientColors[colorIndex],
                      _gradientColors[nextColorIndex], colorTweenValue)!,
                  Colors.black,
                ],
                stops: const [0.1, 0.9],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // تأثير الجسيمات في الخلفية
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlesPainter(30),
              ),
            ),

            // خطوط متقاطعة في الخلفية
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(),
              ),
            ),

            // المحتوى الرئيسي
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // شعار الروبوت مع تأثير الطفو
                  AnimatedBuilder(
                    animation: _robotAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _robotAnimation.value),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Colors.cyanAccent,
                                Colors.purpleAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/robot_welcome.gif',
                            height: screenHeight * 0.18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // العنوان الرئيسي مع تأثير الظل
                  FadeTransition(
                    opacity: _textAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _textAnimationController,
                        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                      )),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.cyanAccent,
                              Colors.purpleAccent,
                            ],
                            stops: const [0.3, 0.7],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'A PLUS',
                          style: TextStyle(
                            fontSize: screenHeight * 0.05,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // النص الفرعي
                  FadeTransition(
                    opacity: _textAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _textAnimationController,
                        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                      )),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Text(
                          'مرحبًا بكم في برنامجنا الخاص بمادة اللغة الإنجليزية للصف السادس',
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // زر التسجيل مع تأثير النبض
                  FadeTransition(
                    opacity: _textAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _textAnimationController,
                        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                      )),
                      child: LoginPulseAnimation(
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _startRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.022),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 12,
                              shadowColor: Colors.cyanAccent.withOpacity(0.7),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018),
                              child: _isLoading
                                  ? SizedBox(
                                      width: screenHeight * 0.025,
                                      height: screenHeight * 0.025,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'بدء التسجيل',
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.022,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: screenHeight * 0.028,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // نص تذييلي
                  SizedBox(height: screenHeight * 0.04),
                  FadeTransition(
                    opacity: _textAnimationController,
                    child: Text(
                      ' انطلق في رحلة تعلم مادة اللغة الإنجليزية بطريقة تفاعلية ومتطورة',
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: Colors.white.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تأثير النبض للزر
class LoginPulseAnimation extends StatefulWidget {
  final Widget child;

  const LoginPulseAnimation({super.key, required this.child});

  @override
  State<LoginPulseAnimation> createState() => _LoginPulseAnimationState();
}

class _LoginPulseAnimationState extends State<LoginPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ===== صفحة تسجيل رقم الهاتف =====
class PhoneRegistrationPage extends StatefulWidget {
  const PhoneRegistrationPage({super.key});

  @override
  State<PhoneRegistrationPage> createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // إضافة الرمز البريدي للعراق تلقائياً
    _phoneController.text = '+964 ';
    // وضع المؤشر في نهاية النص
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );

    // تهيئة التحريك
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _proceedToName() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phoneNumber = _phoneController.text.trim();

      // تخطي البحث في قاعدة البيانات والمتابعة مباشرة إلى إدخال الاسم
      setState(() {
        _isLoading = false;
      });

      // الانتقال مباشرة إلى صفحة إدخال الاسم (للمستخدمين الجدد)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NameRegistrationPage(
            phoneNumber: phoneNumber,
          ),
        ),
      );
    }
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security_rounded,
                        color: Colors.cyanAccent, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'شروط الاستخدام - A PLUS',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // بنود الشروط
                _buildTermItem('1. الحساب شخصي',
                    'الحساب شخصي ولا يجوز مشاركته مع الآخرين. كل حساب مرتبط برقم هاتف واحد فقط.'),

                _buildTermItem('2. الملكية الفكرية',
                    'جميع الدروس والمحتوى ملكية فكرية للمنصة ولا يجوز نسخها أو توزيعها أو إعادة استخدامها بأي شكل دون إذن مسبق.'),

                _buildTermItem('3. الخصوصية',
                    'تُستخدم بياناتك فقط لتحسين الخدمة وتجربة المستخدم ولن تتم مشاركتها مع أي طرف آخر.'),

                _buildTermItem('4. توفر الخدمة',
                    'قد تحدث انقطاعات مؤقتة بسبب الصيانة أو التحديثات أو ظروف تقنية خارجة عن إرادتنا.'),

                _buildTermItem('5. التعديلات',
                    'يمكن تعديل الشروط والأحكام وسيتم إعلامك بالتغييرات عبر التطبيق.'),

                const SizedBox(height: 20),

                Text(
                  'باستخدامك للتطبيق، فأنت تؤكد موافقتك على هذه الشروط والأحكام.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('موافق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 150), () {
              Navigator.pop(context);
            });
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان الرئيسي
                          const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // النص التوضيحي
                          Text(
                            'أدخل رقم هاتفك للبدء في رحلة التعلم',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // نموذج إدخال رقم الهاتف
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                hintText: '+964 7XX XXX XXXX',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5)),
                                prefixIcon: const Icon(
                                    Icons.phone_iphone_rounded,
                                    color: Colors.cyanAccent),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.cyanAccent,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال رقم الهاتف';
                                }
                                if (value.length < 10) {
                                  return 'رقم الهاتف غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          // زر المتابعة
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _proceedToName,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 8,
                                shadowColor: Colors.cyanAccent.withOpacity(0.5),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.cyanAccent,
                                      Colors.purpleAccent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'المتابعة',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // قسم شروط الاستخدام
                          GestureDetector(
                            onTap: _showTermsAndConditions,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.cyanAccent.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.security_rounded,
                                          color: Colors.cyanAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'شروط الاستخدام - A PLUS',
                                        style: TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'باستخدامك للتطبيق فأنت توافق على الشروط والأحكام...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'انقر هنا لقراءة الشروط الكاملة',
                                      style: TextStyle(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // مساحة إضافية في الأسفل لمنع التداخل مع الكيبورد
                          const SizedBox(height: 250),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ... (الكود السابق)
// ===== صفحة تسجيل الاسم - مع حفظ البيانات في Firebase =====
// تم تعديل هذه الصفحة لإزالة استدعاء دالة الحفظ الخاطئ.
// الآن يتم تمرير البيانات إلى صفحة التحقق ليتم حفظها بعد تسجيل الدخول.
class NameRegistrationPage extends StatefulWidget {
  final String phoneNumber;

  const NameRegistrationPage({super.key, required this.phoneNumber});

  @override
  State<NameRegistrationPage> createState() => _NameRegistrationPageState();
}

class _NameRegistrationPageState extends State<NameRegistrationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  /// 🔴 دالة لم تعد مستخدمة: تم نقل منطق الحفظ إلى صفحة التحقق
  void saveUserInfo(String name, String phone) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.set({
        'name': name,
        'phone': phone,
        'isPremium': false,
        'activatedAt': null,
      });
    }
  }

  /// 🟢 عند الضغط على زر المتابعة
  void _proceedToVerification() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 🔴 تم حذف استدعاء دالة saveUserInfo من هنا
      // لأن المستخدم لم يتم توثيقه بعد.

      // إضافة تأخير بسيط لتجربة المستخدم
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => VerificationPage(
              phoneNumber: widget.phoneNumber,
              userName: _nameController.text.trim(),
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تسجيل الاسم',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل اسمك الكامل للاستمرار في رحلة التعلم',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(
                              labelText: 'الاسم الكامل',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              hintText: 'مثال: أحمد محمد',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              prefixIcon: const Icon(Icons.person_rounded,
                                  color: Colors.cyanAccent),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.cyanAccent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال الاسم';
                              }
                              if (value.length < 2) {
                                return 'الاسم يجب أن يكون على الأقل حرفين';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _proceedToVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.cyanAccent.withOpacity(0.5),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'المتابعة',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===== صفحة التحقق - تصميم جديد ومحسن =====
// تم تعديل هذه الصفحة لاستقبال الاسم، وهي التي ستقوم بحفظه في قاعدة البيانات.
class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const VerificationPage({
    super.key,
    required this.phoneNumber,
    required this.userName,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _smsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _verificationId;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();

    // تهيئة التحريك
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _sendVerificationCode() async {
    setState(() => _isLoading = true);

    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted:
          (firebase_auth.PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _signInWithCredential(
      firebase_auth.PhoneAuthCredential credential) async {
    try {
      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final userRef =
            FirebaseDatabase.instance.ref('users/${userCredential.user!.uid}');

        // نستخدم get() للحصول على البيانات الحالية للمستخدم
        final snapshot = await userRef.get();

        // إذا كان المستخدم جديدًا، سنقوم بحفظ كل البيانات دفعة واحدة
        if (!snapshot.exists) {
          final userData = {
            'phone': widget.phoneNumber,
            'name': widget.userName,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'lastLogin': DateTime.now().millisecondsSinceEpoch,
            'isPremium': false,
            'fcmToken': fcmToken,
          };
          await userRef.set(userData);
        } else {
          // إذا كان المستخدم موجودًا، سنقوم بتحديث البيانات الضرورية
          await userRef.update({
            'name': widget.userName, // يجب تحديث الاسم دائمًا
            'phone': widget.phoneNumber, // يجب تحديث الرقم دائمًا
            'lastLogin': DateTime.now().millisecondsSinceEpoch,
            'fcmToken': fcmToken,
          });
        }

        // باقي الكود الخاص بالاشتراكات
        FirebaseMessaging.instance.subscribeToTopic('all_users');
        final codesRef = FirebaseDatabase.instance.ref('activation_codes');
        final activatedCodeSnapshot = await codesRef
            .orderByChild('isUsedBy')
            .equalTo(widget.phoneNumber)
            .once();
        if (activatedCodeSnapshot.snapshot.exists) {
          final codeData = Map<String, dynamic>.from(
                  activatedCodeSnapshot.snapshot.value as Map)
              .values
              .first as Map;
          final validUntilTimestamp = codeData['validUntil'] as int?;
          if (validUntilTimestamp != null &&
              DateTime.now().isBefore(
                  DateTime.fromMillisecondsSinceEpoch(validUntilTimestamp))) {
            await userRef.update(
                {'isPremium': true, 'activationCode': codeData['code']});
          }
        }

        if (mounted) {
          Future.delayed(const Duration(milliseconds: 50), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeRobotPage()),
              (route) => false,
            );
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _verifyCode() async {
    if (_formKey.currentState!.validate() && _verificationId != null) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text.trim(),
      );

      await _signInWithCredential(credential);
    }
  }

  @override
  void dispose() {
    _smsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان الرئيسي
                        const Text(
                          'التحقق من الرمز',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // النص التوضيحي
                        Text(
                          'أدخل الرمز المكون من 6 أرقام المرسل إلى\n${widget.phoneNumber}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // نموذج إدخال رمز التحقق
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _smsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            maxLength: 6,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'ـــ ـــ ـــ',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 24,
                                letterSpacing: 8,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.cyanAccent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رمز التحقق';
                              }
                              if (value.length != 6) {
                                return 'يجب أن يكون الرمز 6 أرقام';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Spacer(),

                        // زر التحقق
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.cyanAccent.withOpacity(0.5),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'تحقق',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// رسام الجسيمات للخلفية
class _ParticlesPainter extends CustomPainter {
  final int numberOfParticles;

  _ParticlesPainter(this.numberOfParticles);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numberOfParticles; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// ===== نوع بيانات لتحديد حالة الروبوت =====
enum RobotMood { welcome, talking, thinking, happy, sad, correcting }

// ===== ويدجت المساعد الافتراضي الديناميكي =====
class DynamicRobotAssistant extends StatefulWidget {
  final String message;
  final RobotMood mood;
  final bool isLarge;
  final bool isHorizontal;

  const DynamicRobotAssistant({
    super.key,
    required this.message,
    required this.mood,
    this.isLarge = false,
    this.isHorizontal = false,
  });

  @override
  State<DynamicRobotAssistant> createState() => _DynamicRobotAssistantState();
}

class _DynamicRobotAssistantState extends State<DynamicRobotAssistant> {
  late String _robotGifPath;

  @override
  void didUpdateWidget(covariant DynamicRobotAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood != oldWidget.mood) {
      _updateRobotGif();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateRobotGif();
  }

  void _updateRobotGif() {
    String newPath;
    switch (widget.mood) {
      case RobotMood.welcome:
        newPath = 'assets/robot_welcome.gif';
        break;
      case RobotMood.talking:
        newPath = 'assets/robot_talking.gif';
        break;
      case RobotMood.thinking:
        newPath = 'assets/robot_thinking.gif';
        break;
      case RobotMood.happy:
        newPath = 'assets/robot_happy.gif';
        break;
      case RobotMood.sad:
        newPath = 'assets/robot_sad.gif';
        break;
      case RobotMood.correcting:
        newPath = 'assets/robot_corrector.gif'; // المسار الجديد
        break;
    }
    setState(() {
      _robotGifPath = newPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double gifHeight = widget.isLarge ? 220 : 80;
    final EdgeInsets padding =
        widget.isLarge ? const EdgeInsets.all(24) : const EdgeInsets.all(12);
    final Color textColor = Colors.white;
    final Color backgroundColor = Colors.grey.withOpacity(0.1);
    final Color borderColor = Theme.of(
      context,
    ).colorScheme.primary.withOpacity(0.6);
    final double borderWidth = 1.5;
    final BorderRadius borderRadius = BorderRadius.circular(18);
    final TextStyle textStyle = TextStyle(
      fontSize: widget.isLarge ? 20 : 14,
      color: textColor,
    );
    if (widget.isHorizontal) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Text(
                widget.message,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(_robotGifPath, height: gifHeight),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: widget.isLarge
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.isLarge)
              Expanded(
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Text(
                    widget.message,
                    style: textStyle,
                    textDirection: TextDirection.rtl, // إضافة هذا السطر
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Image.asset(_robotGifPath, height: gifHeight),
            if (widget.isLarge) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Text(
                    widget.message,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl, // إضافة هذا السطر
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}

// ===== صفحة الترحيب الكبيرة الجديدة للروبوت - تصميم متطور =====
class WelcomeRobotPage extends StatefulWidget {
  const WelcomeRobotPage({super.key});

  @override
  State<WelcomeRobotPage> createState() => _WelcomeRobotPageState();
}

class _WelcomeRobotPageState extends State<WelcomeRobotPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // تأثير الجسيمات في الخلفية
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlesPainter(30),
              ),
            ),

            // خطوط متقاطعة في الخلفية
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الروبوت مع تأثيرات متحركة
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _slideAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyanAccent.withOpacity(0.8),
                              Colors.purpleAccent.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/robot_welcome.gif',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // رسالة الترحيب
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.cyanAccent,
                              Colors.purpleAccent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'A PLUS\nمرحباً بك',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // النص الفرعي
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        ' استعد لخوض تجربة تعليمية فريدة في مادة اللغة الإنجليزية، بطريقة ذكية، ممتعة وتفاعلية مع روبوتك المساعد',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // زر البدء
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LessonsHomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.cyanAccent.withOpacity(0.5),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyanAccent,
                                Colors.purpleAccent,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'انطلق',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// رسام نمط الشبكة للخلفية
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // خطوط أفقية
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // خطوط عمودية
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// في بداية ملف main.dart، قبل أي كلاس
final GlobalKey<_LessonsHomePageState> lessonsHomePageKey =
    GlobalKey<_LessonsHomePageState>();

// ... (بقية الكود) ...

// ===== صفحة الفصول مع قائمة جانبية - تصميم عصري ومميز =====
class LessonsHomePage extends StatefulWidget {
  const LessonsHomePage({Key? key}) : super(key: key);

  @override
  State<LessonsHomePage> createState() => _LessonsHomePageState();
}

class _LessonsHomePageState extends State<LessonsHomePage>
    with SingleTickerProviderStateMixin {
  final List<String> chapters = [
    'الفصل الأول: UNIT 1',
    'الفصل الثاني: UNIT 2',
    'الفصل الثالث: UNIT 3',
    'الفصل الرابع: UNIT 4',
    'الفصل الخامس: UNIT 5',
    'الفصل السادس: UNIT 6',
    'الفصل السابع: UNIT 7',
    'الفصل الثامن: UNIT 8',
    'الأدب - القطعة الخارجية - الأفعال الشاذة',
  ];

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  String _userName = '';
  String _phoneNumber = '';
  String? _userPhotoPath;
  bool _isPremiumUser = false;
  final TextEditingController _codeController = TextEditingController();
  final SessionManager _sessionManager = SessionManager();
  String? _activatedAtDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });

    _loadUserInfo();
    _loadUserPhoto();
    _checkAndManageSubscription();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  // دالة جديدة للتحقق من صلاحية الاشتراك
  void _checkAndManageSubscription() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      final snapshot = await userRef.once();
      if (snapshot.snapshot.exists) {
        final userData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        final validUntilTimestamp = userData['validUntil'] as int?;

        if (validUntilTimestamp != null) {
          final validUntilDate =
              DateTime.fromMillisecondsSinceEpoch(validUntilTimestamp);
          final now = DateTime.now();

          if (now.isAfter(validUntilDate)) {
            // انتهت الصلاحية، إلغاء التفعيل
            if (userData['isPremium'] == true) {
              await userRef.update({
                'isPremium': false,
                'activationCode': null,
                'validUntil': null
              });
              setState(() {
                _isPremiumUser = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('انتهت صلاحية تفعيل حسابك.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            // الحساب لا يزال مفعلاً، قم بالتأكد
            setState(() {
              _isPremiumUser = true;
            });
          }
        } else {
          // لا يوجد تاريخ انتهاء، قم بإلغاء التفعيل إذا كان مفعلاً
          if (userData['isPremium'] == true) {
            await userRef.update({'isPremium': false});
            setState(() {
              _isPremiumUser = false;
            });
          }
        }
      }
    }
  }

  // تعديل دالة تحميل معلومات المستخدم
  void _loadUserInfo() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseDatabase.instance.ref('users/${user.uid}').once();
      if (snapshot.snapshot.value != null) {
        final userData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          _userName = userData['name'] ?? 'مستخدم جديد';
          _phoneNumber = userData['phone'] ?? 'لا يوجد رقم';
          _isPremiumUser = userData['isPremium'] ?? false;

          final activatedAtTimestamp = userData['activatedAt'] as int?;
          if (activatedAtTimestamp != null) {
            final activatedDate =
                DateTime.fromMillisecondsSinceEpoch(activatedAtTimestamp);
            final formatter = intl.DateFormat('yyyy-MM-dd HH:mm:ss');
            _activatedAtDate = formatter.format(activatedDate);
          } else {
            _activatedAtDate = null;
          }
        });
        if (!_isPremiumUser) {
          // إذا كان المستخدم غير مفعل، تحقق من رقم هاتفه في الأكواد المفعلة
          _checkPhoneInUsedCodes(userData['phone']);
        }
      }
    }
  }

  // دالة جديدة للتحقق من رقم الهاتف في الأكواد المفعلة
  void _checkPhoneInUsedCodes(String? phoneNumber) async {
    if (phoneNumber == null) return;

    final codesRef = FirebaseDatabase.instance.ref('activation_codes');
    final snapshot =
        await codesRef.orderByChild('isUsedBy').equalTo(phoneNumber).once();

    if (snapshot.snapshot.value != null) {
      final codeData = Map<String, dynamic>.from(snapshot.snapshot.value as Map)
          .values
          .first as Map;
      final validUntilTimestamp = codeData['validUntil'] as int?;

      if (validUntilTimestamp != null) {
        final validUntilDate =
            DateTime.fromMillisecondsSinceEpoch(validUntilTimestamp);
        if (DateTime.now().isBefore(validUntilDate)) {
          // إذا كان الكود لا يزال صالحًا، قم بتفعيل الحساب للمستخدم الحالي
          final user = firebase_auth.FirebaseAuth.instance.currentUser;
          if (user != null) {
            final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
            await userRef.update({
              'isPremium': true,
              'activationCode': codeData['code'],
              'activatedAt': codeData['activatedAt'],
              'validUntil': validUntilTimestamp,
            });
            setState(() {
              _isPremiumUser = true;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تفعيل حسابك تلقائيًا بناءً على رقم هاتفك.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    }
  }

  // دالة لحفظ الصورة في SharedPreferences
  void _saveUserPhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_path', path);
    setState(() {
      _userPhotoPath = path;
    });
  }

  // دالة لتحميل الصورة من SharedPreferences
  void _loadUserPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userPhotoPath = prefs.getString('user_photo_path');
    });
  }

  // دالة لتسجيل الخروج
  void _signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // دالة لاختيار الصورة من المعرض
  void _showPhotoPicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _saveUserPhoto(image.path);
    }
  }

  // تعديل دالة التفعيل
  void _activateAccount() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null || _codeController.text.isEmpty) {
      return;
    }

    final code = _codeController.text.trim();
    final codesRef = FirebaseDatabase.instance.ref('activation_codes');
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    // 1. التحقق من الكود
    final snapshot = await codesRef.child(code).get();

    if (snapshot.exists) {
      final codeData = Map<String, dynamic>.from(snapshot.value as Map);
      if (codeData['isUsed'] == false) {
        // حساب تاريخ الانتهاء
        final validUntil = DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch;

        // 2. تحديث حالة الكود في قاعدة البيانات إلى مستخدم
        await codesRef.child(code).update({
          'isUsed': true,
          'isUsedBy': _phoneNumber, // حفظ رقم هاتف المستخدم
          'activatedAt': DateTime.now().millisecondsSinceEpoch,
          'validUntil': validUntil,
        });

        // 3. تفعيل الحساب بشكل دائم للمستخدم
        await userRef.update({
          'isPremium': true,
          'activationCode': code,
          'activatedAt': DateTime.now().millisecondsSinceEpoch,
          'validUntil': validUntil,
        });

        if (mounted) {
          setState(() {
            _isPremiumUser = true;
          });
          Navigator.pop(context); // إغلاق الحوار
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تفعيل الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هذا الكود مستخدم بالفعل.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الكود غير صالح.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // تعديل دالة عرض حوار التفعيل
  void _showActivationDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل كود التفعيل',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // حقل إدخال الكود
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'أدخل الكود هنا',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.cyanAccent, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // رابط الموقع
              ElevatedButton(
                onPressed: () async {
                  const url = 'https://princealaa7.github.io/A-PLUS/';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر فتح الموقع'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.purpleAccent.withOpacity(0.5),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 231, 71, 223),
                        Color.fromARGB(255, 26, 199, 229)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_browser_rounded,
                            color: Colors.black, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'ادخل لموقعنا للحصول على الكود',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // أزرار الإجراءات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: _activateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('تفعيل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _continueLesson() async {
    final lastLesson = await getLastLesson();
    if (lastLesson['chapter'] != null && lastLesson['lesson'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonsVideosPage(
            chapterNumber: lastLesson['chapter']!,
            lessonNumber: lastLesson['lesson']!,
            initialVideoIndex: 0,
            isStartingLesson: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يوجد درس لإكماله. ابدأ درساً جديداً أولاً.'),
          backgroundColor: Colors.purpleAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: lessonsHomePageKey, // إضافة المفتاح هنا
      appBar: AppBar(
        title: const Text('الفصول الدراسية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.2),
                Colors.purpleAccent.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // مساعد الروبوت
                      Container(
                        constraints: const BoxConstraints(minHeight: 80),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const DynamicRobotAssistant(
                          message:
                              'اختر فصلاً لاستكشاف مغامرة التعلم، او استأنف رحلتك من حيث توقفت. 🤖',
                          mood: RobotMood.talking,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // قائمة الفصول
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            return AnimatedContainer(
                              duration: Duration(
                                  milliseconds: 300 + (index * 100).toInt()),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: _buildChapterCard(index),
                            );
                          },
                        ),
                      ),
                      // زر استئناف الدرس
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 20,
                        ),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(0, 30 * (1 - _opacityAnimation.value)),
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _continueLesson,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Colors.cyanAccent.withOpacity(0.5),
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.cyanAccent,
                                      Colors.purpleAccent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'استئناف آخر درس',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(int index) {
    final bool isEven = index % 2 == 0;
    final bool isLocked = index > 0 && !_isPremiumUser;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () {
          if (isLocked) {
            _showActivationMessage();
          } else {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LessonsListPage(
                  chapterNumber: index + 1,
                  isPremiumUser: _isPremiumUser,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isEven ? Alignment.topLeft : Alignment.topRight,
              end: isEven ? Alignment.bottomRight : Alignment.bottomLeft,
              colors: [
                Colors.cyanAccent.withOpacity(0.15),
                Colors.purpleAccent.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // تأثير خلفية متحركة
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.cyanAccent.withOpacity(0.05),
                            Colors.purpleAccent.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // نمط شبكي خفيف
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPatternPainter(),
                    ),
                  ),
                  // محتوى البطاقة
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // رقم الفصل في دائرة
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyanAccent,
                                Colors.purpleAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // عنوان الفصل
                        Expanded(
                          child: Text(
                            chapters[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // أيقونة السهم أو القفل
                        if (isLocked)
                          const Icon(
                            Icons.lock_rounded,
                            color: Colors.redAccent,
                            size: 24,
                          )
                        else
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // في دالة _buildDrawer()
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey.shade900.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027).withOpacity(0.95),
              const Color(0xFF203A43).withOpacity(0.95),
              const Color(0xFF2C5364).withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // رأس الدراور الجديد
                  _buildDrawerHeader(),
                  // إضافة زر معلومات الحساب
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'معلومات الحساب',
                    onTap: () {
                      Navigator.pop(context);
                      _showAccountInfo();
                    },
                  ),
                  // زر تفعيل الحساب
                  if (!_isPremiumUser)
                    _buildDrawerItem(
                      icon: Icons.vpn_key_rounded,
                      title: 'تفعيل الحساب (أدخل الكود)',
                      onTap: () {
                        Navigator.pop(context);
                        _showActivationDialog();
                      },
                    ),

                  // ... (بقية عناصر القائمة)
                  _buildDrawerItem(
                    icon: Icons.chat_rounded,
                    title: 'الدردشة',
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchURL('https://t.me/+qkbZbGXKYD8yZjYy');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'التواصل مع أستاذ المادة',
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchURL('https://wa.me/+9647879666830');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'إحصائياتي ',
                    onTap: () async {
                      Navigator.pop(context);
                      _showProgressStatistics();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'حول التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                  // إضافة زر تسجيل الخروج
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
            // ... (بقية كود الدراور)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 5),
                  const Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/instagram.png', height: 30),
                        onPressed: () {
                          _launchURL(
                              'https://www.instagram.com/a.plus.x?igsh=emI0dmNsZmFvajRz');
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/tiktok.png', height: 30),
                        onPressed: () {
                          _launchURL(
                              'https://www.tiktok.com/@aplusiraq?_t=ZS-8zWa908kOYf&_r=1');
                        },
                      ),
                      IconButton(
                        icon: Image.asset('assets/facebook.png', height: 30),
                        onPressed: () {
                          _launchURL(
                              'https://www.facebook.com/share/1CdVpH2NbB/');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة جديدة لبناء رأس القائمة الجانبية
  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyanAccent.withOpacity(0.8),
            Colors.purpleAccent.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          GestureDetector(
            onTap: _showPhotoPicker, // دالة اختيار الصورة
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                image: _userPhotoPath != null && _userPhotoPath!.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(_userPhotoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _userPhotoPath == null || _userPhotoPath!.isEmpty
                  ? const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 30,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _phoneNumber,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountInfo() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'معلومات الحساب',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // معلومات رقم الهاتف
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_rounded, color: Colors.cyanAccent),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'رقم الهاتف',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _phoneNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // معلومات الاسم مع زر التعديل
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, color: Colors.cyanAccent),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الاسم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _changeName();
                      },
                      icon: const Icon(Icons.edit_rounded,
                          color: Colors.purpleAccent),
                      tooltip: 'تغيير الاسم',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // حالة الحساب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPremiumUser
                      ? Colors.green.shade900.withOpacity(0.3)
                      : Colors.red.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        _isPremiumUser ? Colors.greenAccent : Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPremiumUser
                          ? Icons.verified_rounded
                          : Icons.lock_open_rounded,
                      color: _isPremiumUser
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isPremiumUser
                          ? 'تم استرداد الكود'
                          : ': لم يتم استرداد الكود',
                      style: TextStyle(
                        color: _isPremiumUser
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // **إضافة جديدة هنا لعرض تاريخ التفعيل**
              if (_isPremiumUser && _activatedAtDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    children: [
                      const Text(
                        'تاريخ التفعيل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _activatedAtDate!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              // زر الإغلاق
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة جديدة لفتح صفحة تغيير الاسم
  void _changeName() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNamePage(
          initialName: _userName,
          onNameChanged: (newName) {
            setState(() {
              _userName = newName;
            });
          },
        ),
      ),
    );
  }

  // رسالة تنبيه عند محاولة فتح محتوى مقفل
  void _showActivationMessage() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'هذا الفصل مقفل 🔒',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'لفتح جميع الفصول والدروس، يرجى استرداد الرمز.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showActivationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('أدخل الكود الآن'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح الرابط: $url'),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      minLeadingWidth: 20,
    );
  }

  void _showProgressStatistics() async {
    // جلب البيانات من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final scores = <String, Map<String, int>>{};

    for (int i = 1; i <= 9; i++) {
      final lastScore = prefs.getInt('chapter${i}_score') ?? 0;
      final bestScore = prefs.getInt('chapter${i}_best_score') ?? 0;

      scores['الفصل $i'] = {
        'last_score': lastScore,
        'best_score': bestScore,
      };
    }

    // حساب المتوسط العام
    double totalLast = 0;
    double totalBest = 0;
    int validChapters = 0;

    scores.forEach((key, value) {
      if (value['last_score']! > 0) {
        totalLast += value['last_score']!;
        totalBest += value['best_score']!;
        validChapters++;
      }
    });

    final averageLast =
        validChapters > 0 ? (totalLast / validChapters).round() : 0;
    final averageBest =
        validChapters > 0 ? (totalBest / validChapters).round() : 0;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '📊 إحصائيات تقدمك',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // المتوسط العام
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'المتوسط العام',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreCard(
                              'آخر اختبار', averageLast, Colors.cyanAccent),
                          _buildScoreCard(
                              'أعلى درجة', averageBest, Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'النتائج التفصيلية لكل فصل',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // قائمة الفصول
                ...scores.entries.map((entry) {
                  final chapterName = entry.key;
                  final chapterScores = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapterName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniScore(
                                'آخر اختبار',
                                chapterScores['last_score']!,
                                Colors.cyanAccent),
                            _buildMiniScore(
                                'أعلى درجة',
                                chapterScores['best_score']!,
                                Colors.purpleAccent),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // شريط التقدم
                        LinearProgressIndicator(
                          value: chapterScores['best_score']! / 100,
                          backgroundColor: Colors.grey.shade600,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(chapterScores['best_score']!),
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'حول التطبيق',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'تم ابتكار هذا التطبيق ليكون وسيلة حديثة لتعلّم مادة اللغة الإنجليزية للصف السادس الأعدادي بأسلوب تفاعلي وسهل الفهم، تحت إشراف الأستاذ م.م.جمال خضر، وبتطوير من علاء عباس، ليجمع بين الخبرة التعليمية والابتكار التقني',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  final Uri instagramUri =
                      Uri.parse('https://www.instagram.com/princealaa7/');
                  if (await canLaunchUrl(instagramUri)) {
                    await launchUrl(instagramUri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تعذر فتح رابط التواصل')),
                    );
                  }
                },
                child: const Text(
                  'تواصل مع المطور',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score%',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniScore(String title, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score/100',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    if (score >= 40) return Colors.yellowAccent;
    return Colors.redAccent;
  }
}

// ===== صفحات جديدة لإنشاءها =====
// صفحة تغيير الاسم
class ChangeNamePage extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;

  const ChangeNamePage({
    required this.initialName,
    required this.onNameChanged,
    super.key,
  });

  @override
  State<ChangeNamePage> createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  void _updateName() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لم يتم العثور على المستخدم'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الاسم لا يمكن أن يكون فارغاً'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseDatabase.instance.ref('users/${user.uid}').update({
        'name': _nameController.text.trim(),
      });
      widget.onNameChanged(_nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تحديث الاسم بنجاح'),
            backgroundColor: Colors.greenAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التحديث: $e'),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تغيير الاسم',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.2),
                Colors.purpleAccent.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تعديل الاسم الشخصي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الاسم الجديد',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'أدخل اسمك الكامل',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.cyanAccent, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person_rounded,
                        color: Colors.cyanAccent),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.cyanAccent.withOpacity(0.5),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.cyanAccent,
                            Colors.purpleAccent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.black, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'حفظ التغييرات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== صفحة الدروس داخل الفصل (تصميم جديد ومبهر) =====
class LessonsListPage extends StatefulWidget {
  final int chapterNumber;
  final bool isPremiumUser;

  const LessonsListPage({
    super.key,
    required this.chapterNumber,
    required this.isPremiumUser,
  });

  @override
  State<LessonsListPage> createState() => _LessonsListPageState();
}

class _LessonsListPageState extends State<LessonsListPage> {
  final SessionManager _sessionManager = SessionManager();
  late final PageController _pageController;
  int _currentPageIndex = 0;

  final List<String> robotMessages = [
    'استعرض دروس الفصل، او اختبر نفسك',
    "الماضي البسيط يعبر عن حدث انتهى في وقت محدد بالماضي",
    "الماضي المستمر يتكون من was/were + ing ويصف حدثًا طويلًا",
    "الماضي البسيط يقاطع الماضي المستمر باستخدام when/while",
    "الصفة المنتهية بـ ed تصف شعور الشخص",
    "الصفة المنتهية بـ ing تصف الشيء المسبب للشعور",
    "جملة الأمر تبدأ بفعل مجرد وتستخدم للنصيحة أو التعليمات",
    "المضارع البسيط يستخدم للحقائق والعادات والروتين",
    "في المضارع البسيط نضيف s/es للفعل مع he/she/it",
    "النفي في المضارع البسيط يتم بـ doesn’t أو don’t + فعل مجرد",
    "السؤال في المضارع البسيط يبدأ بـ Do/Does + فاعل",
    "الأسماء المعدودة تأخذ many والأسماء غير المعدودة تأخذ much",
    "إضافة in-, im-, il-, ir-, un- تجعل الكلمة عكس معناها",
    "المضارع المستمر يتكون من am/is/are + ing ويعبر عن حدث يجري الآن",
    "الكلمات الدالة على المضارع المستمر هي now, at the moment, look, listen",
    "بعض الأفعال لا تأتي بالمستمر مثل know, like, want",
    "will يستخدم للقرار اللحظي أو التنبؤ",
    "be going to يستخدم للخطط والنوايا المستقبلية",
    "shall تستخدم مع I/We للعرض أو الاقتراح",
    "المضارع التام يتكون من have/has + p.p ويعبر عن تجربة أو حدث غير محدد الوقت",
    "since تستخدم مع وقت محدد، for تستخدم مع مدة زمنية",
    "already و just تأتي مع الجملة المثبتة في المضارع التام",
    "yet تأتي في نهاية الجملة المنفية أو السؤال",
    "ever تستخدم في الأسئلة وnever تستخدم للنفي",
    "الفرق بين المضارع التام والماضي البسيط أن الماضي يحدد وقتًا والمضارع لا يحدد",
    "المستقبل التام يتكون من will have + p.p ويعبر عن حدث ينتهي قبل وقت مستقبلي",
    "المستقبل المستمر يتكون من will be + ing ويعبر عن حدث سيستمر وقتًا معينًا",
    "الكلام المنقول يحول الأزمنة خطوة للوراء",
    "الضمائر تتغير في الكلام المنقول I → he/she",
    "الظروف الزمنية تتغير tomorrow → the next day",
    "this تتحول إلى that وthese تتحول إلى those في الكلام المنقول",
    "المبني للمجهول يتكون من object + be + p.p",
    "المبني للمجهول يستخدم عندما لا يهم الفاعل أو لا يُذكر",
    "المبني للمجهول في المضارع البسيط هو am/is/are + p.p",
    "المبني للمجهول في الماضي البسيط هو was/were + p.p",
    "المبني للمجهول في المستقبل هو will be + p.p",
    "المبني للمجهول في المضارع التام هو have/has been + p.p",
    "المقارنة للصفات القصيرة تكون بإضافة er + than",
    "التفضيل للصفات القصيرة يكون the + adj + est",
    "الصفات الطويلة تستخدم more في المقارنة وthe most في التفضيل",
    "الصفات الشاذة: good → better → best",
    "الصفات الشاذة: bad → worse → worst",
    "as … as تستخدم للمساواة بين شيئين",
    "النوع الأول من if: If + present simple, will + base verb",
    "النوع الثاني من if: If + past simple, would + base verb",
    "النوع الثالث من if: If + past perfect, would have + p.p",
    "unless تعني if not وتستخدم بنفس الطريقة",
    "wish + past simple يعبر عن تمني في الحاضر",
    "wish + past perfect يعبر عن ندم على الماضي",
    "wish + would + base verb يعبر عن رغبة في التغيير بالمستقبل",
    "if النوع الأول يعبر عن احتمال واقعي",
    "أنت قادر على تحقيق النجاح",
    "كل يوم فرصة جديدة للتعلم",
    "الثقة بالنفس هي مفتاح التقدم",
    "الخطأ خطوة نحو النجاح",
    "تعلم شيئًا جديدًا كل يوم",
    "اصبر، فالنجاح يحتاج وقتًا",
    "العمل الجاد يصنع الفرق",
    "آمن بقدراتك دائمًا",
    "لا تيأس مهما كانت الصعوبات",
    "رحلتك التعليمية تستحق الجهد"
  ];

  final Map<int, Map<int, String>> chapterLessonContents = {
    1: {
      1: '"Toe is bleeding" إصبع قدمي ينزف (كلمات مهمة)\nالفرق بين: pain - sore - hurt',
      2: 'Past Simple Tense: زمن الماضي البسيط\nPast Continuous Tense: زمن الماضي المستمر\nالعلاقة بين الماضي البسيط والماضي المستمر',
      3: 'قطعة:  Ammar\nالصفات المنتهية بـ -ed و -ing\nAdjectives and Adverbs: الصفات والظروف',
      4: 'Present Simple: المضارع البسيط\nPhrasal Verbs: الأفعال المركبة\nPrefixes (meaning not): إضافات النفي في بداية الكلمة',
      5: 'Imperative: جملة الأمر\nCountable & Uncountable Nouns: الأسماء المعدودة وغير المعدودة\nExpressions of Quantity: تعابير الكمية',
      6: 'Used to: اعتاد على\nالمقارنة بين الماضي والحاضر بـ Used to\nUsed to مع الماضي البسيط والمضارع البسيط',
      7: 'Let’s start with diet: دعنا نبدأ بالنظام الغذائي',
      8: 'Cigarette advertising should be illegal: يجب حظر إعلانات السجائر (إنشاء)',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: '',
    },
    2: {
      1: 'كلمات مهمة عن القانون والنظام: "Law and Order"',
      2: 'قطعة: وظائف ضباط الشرطة "A Police Officer\'s Duties"\nNecessity and Non-Necessity: الضرورة وعدم الضرورة',
      3: 'Polite Request: الطلب المؤدب\nSuggestions: الاقتراحات\nOffers: العروض\nAdvice: النصيحة',
      4: 'Expectation: التوقع\nالمختصرات',
      5: 'Military Jobs: وظائف عسكرية',
      6: 'Causative Verbs: الأفعال السببية (have / get / make)',
      7: 'A Safety Brochure: كتيب أمان',
      8: 'An Advice to a Friend to Get a Job: إنشاء حول الحصول على وظيفة',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: 'Security Technology (Radar): تكنولوجيا الأمن (رادار)',
    },
    3: {
      1: 'أسماء المهن\nJob Definition: تعريف المهنة',
      2: 'Conditional Sentences: الجمل الشرطية',
      3: 'تمارين عن الجمل الشرطية',
      4: 'Reported Speech: الكلام المنقول',
      5: 'Regret: الندم',
      6: 'تمارين عن الجمل الشرطية',
      7: '"Learn English in the UK": تعلم في المملكة المتحدة',
      8: 'The Advantages of Studying English in Britain: فوائد الدراسة في بريطانيا (إنشاء)',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: 'Focus on Careers - Conference Interpreter: مترجم المؤتمرات',
    },
    4: {
      1: 'A Company You Have Recently Set Up (إنشاء)\nتأسيس شركة قمت بإنشائها مؤخرًا\nBad Day / Terrible Day (إنشاء)\nيوم سيئ حقيقي',
      2: 'تمارين مهم',
    },
    5: {
      1: 'Compound nouns: الأسماء المركبة',
      2: 'Present perfect simple : زمن المضارع التام البسيط\n(never, ever, since, for, already, just, so far, yet)',
      3: 'Present Perfect Continuous : زمن المضارع التام المستمر\nHow long',
      4: 'has been / has gone : استخدام',
      5: 'Past Perfect Simple : زمن الماضي التام\nالعلاقة بين الماضي البسيط والماضي التام',
      6: '" The atmosphere was really peaceful" قطعة كانت الأجواء هادئة حقًا',
      7: 'Defining and non-Defining relative clause العبارات الوصلية',
      8: '" A wonderful holiday l have had" انشاء عطلة رائعة',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: '" Why are holidays so important" قطعة (لماذا تعتبر العطلات مهمة للغاية؟)',
    },
    6: {
      1: 'What does it all mean مفردات جديدة',
      2: 'passive voice: المبني للمجهول',
      3: 'Meet a banker',
      4: 'Conditional sentences : تمارين عن الجمل الشرطية',
      5: 'Conditional sentences : تمارين عن الجمل الشرطية',
      6: 'تعاريف',
      7: 'Formal and informal letters الرسائل الرسمية وغير الرسمية',
      8: 'a letter to your bank to complain about a withdrawal رسالة شكوى على البنك',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: 'Making money: جني الأموال',
    },
    7: {
      1: 'إضافات\nWhat can I study مفردات جديدة',
      2: 'Future المستقبل\n- Future simple: المستقبل البسيط\n المضارع المستمر للمستقبل\n "going to" for future\n المستقبل المستمر\nالمضارع البسيط للمستقبل',
      3: 'Work today قطعة',
      4: 'Future in the past :المستقبل في الماضي',
      5: 'Volunteers at the Children\'s Hospital',
      6: 'Learning experiences',
      7: '" Books and the Internet"',
      8: 'Studying while you are working انشاء الدراسة إثناء العمل',
      9: 'Test Yourself: تمارين نهاية الوحدة (اختبر نفسك)',
      10: 'Using the Library : أستعمال المكتبات',
    },
    8: {
      1: '(de/ation) البادئات واللاحقات',
      2: '" A renewable resources Wind power : طاقة الرياح',
      3: '" improve the environment." انشاء تحسين البيئة',
      4: 'تمارين',
    },
    9: {
      1: '',
      2: 'الافعال الشاذه',
      3: 'كيفية الإجابة على القطعة الخارجية',
    },
  };

  final Map<int, int> chapterLessonCounts = {
    1: 10,
    2: 10,
    3: 10,
    4: 2,
    5: 10,
    6: 10,
    7: 10,
    8: 4,
    9: 3,
  };

  late final int _totalLessonCount;
  late String _currentMessage;
  late Timer _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });
    _totalLessonCount = chapterLessonCounts[widget.chapterNumber] ?? 10;
    _pageController = PageController(
      viewportFraction: 0.85,
    );
    _pageController.addListener(() {
      final newPageIndex = _pageController.page?.round() ?? 0;
      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });
      }
    });

    final firstMessage = robotMessages.first;
    final otherMessages = robotMessages.sublist(1);
    otherMessages.shuffle(Random());
    robotMessages.clear();
    robotMessages.add(firstMessage);
    robotMessages.addAll(otherMessages);

    _currentMessage = robotMessages[0];
    _startMessageTimer();
  }

  void _startMessageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeMessage();
    });
  }

  void _changeMessage() {
    _timer.cancel();
    setState(() {
      _messageIndex = (_messageIndex + 1) % robotMessages.length;
      _currentMessage = robotMessages[_messageIndex];
    });
    _startMessageTimer();
  }

  void _showActivationMessage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'هذا الدرس مقفل 🔒',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'لفتح جميع الفصول والدروس، يرجى استرداد الرمز.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sessionManager.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'الفصل ${widget.chapterNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.2),
                Colors.purpleAccent.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مساعد الروبوت المتحرك
              if (!widget.isPremiumUser && widget.chapterNumber == 1)
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: DynamicRobotAssistant(
                    key: ValueKey<int>(_messageIndex),
                    message:
                        'الدروس 1، 2، 3 و 10 من هذا الفصل مجانية. لتفعيل باقي الدروس والفصول، يرجى إدخال كود التفعيل.',
                    mood: RobotMood.talking,
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: GestureDetector(
                    onTap: _changeMessage,
                    child: DynamicRobotAssistant(
                      key: ValueKey<int>(_messageIndex),
                      message: _currentMessage,
                      mood: RobotMood.talking,
                    ),
                  ),
                ),

              // مؤشر التمرير
              if (_currentPageIndex == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_left_rounded,
                          color: Colors.cyanAccent.withOpacity(0.8), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'اسحب لاستعراض الدروس',
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

              // منطقة الدروس الرئيسية
              Expanded(
                child: Stack(
                  children: [
                    // خلفية متحركة
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              Colors.cyanAccent.withOpacity(0.05),
                              Colors.purpleAccent.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // PageView للدروس
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _totalLessonCount,
                      itemBuilder: (context, index) {
                        final lessonNumber = index + 1;
                        final lessonContent =
                            chapterLessonContents[widget.chapterNumber]
                                    ?[lessonNumber] ??
                                'محتوى الدرس غير متاح.';
                        final bool isLessonLocked = !widget.isPremiumUser &&
                            widget.chapterNumber == 1 &&
                            ![1, 2, 3, 10].contains(lessonNumber);

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                            }

                            return Transform(
                              transform: Matrix4.identity()
                                ..scale(value)
                                ..rotateY(value - 1),
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildLessonCard(
                              lessonNumber, lessonContent, index,
                              isLocked: isLessonLocked),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // زر الاختبار
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                    elevation: 10,
                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                  ),
                  onPressed: () {
                    if (allQuizzes.containsKey(widget.chapterNumber)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DynamicQuizPage(
                            chapterNumber: widget.chapterNumber,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'الاختبار غير متاح لهذا الفصل حالياً.',
                            style: TextStyle(color: Colors.white),
                            textDirection: TextDirection.rtl,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent,
                          Colors.purpleAccent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined,
                            color: Colors.black, size: 28),
                        SizedBox(width: 15),
                        Text(
                          'جاهز للاختبار؟ اضغط هنا',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(int lessonNumber, String lessonContent, int index,
      {bool isLocked = false}) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showActivationMessage();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonsVideosPage(
                chapterNumber: widget.chapterNumber,
                lessonNumber: lessonNumber,
                initialVideoIndex: 0,
                isStartingLesson: true,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.withOpacity(0.15),
                Colors.purpleAccent.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // تأثير خلفية متحركة
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.5,
                          colors: [
                            Colors.cyanAccent.withOpacity(0.1),
                            Colors.purpleAccent.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // نمط شبكي خفيف
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPatternPainter(),
                    ),
                  ),

                  // محتوى البطاقة
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رأس البطاقة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'الدرس $lessonNumber',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // محتوى الدرس
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              lessonContent,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // زر التشغيل
                        Align(
                          alignment: Alignment.center,
                          child: isLocked
                              ? const Icon(
                                  Icons.lock_rounded,
                                  size: 48,
                                  color: Colors.redAccent,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.cyanAccent,
                                        Colors.purpleAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LessonsVideosPage(
                                            chapterNumber: widget.chapterNumber,
                                            lessonNumber: lessonNumber,
                                            initialVideoIndex: 0,
                                            isStartingLesson: true,
                                          ),
                                        ),
                                      );
                                    },
                                    iconSize: 32,
                                    padding: const EdgeInsets.all(15),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== صفحة الفيديوهات (عرض شورتس مع الأزرار) =====
class LessonsVideosPage extends StatefulWidget {
  final int chapterNumber;
  final int lessonNumber;
  final int initialVideoIndex;
  final bool isStartingLesson;

  const LessonsVideosPage({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.initialVideoIndex,
    this.isStartingLesson = false,
  });

  @override
  State<LessonsVideosPage> createState() => _LessonsVideosPageState();
}

class _LessonsVideosPageState extends State<LessonsVideosPage> {
  final SessionManager _sessionManager = SessionManager();
  late YoutubePlayerController _controller;
  late List<String> videoIds;
  int _currentVideoIndex = 0;

  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });
    videoIds = lessonsVideos.containsKey(widget.chapterNumber) &&
            lessonsVideos[widget.chapterNumber]!
                .containsKey(widget.lessonNumber)
        ? lessonsVideos[widget.chapterNumber]![widget.lessonNumber]!
        : [];
    _currentVideoIndex = widget.initialVideoIndex;
    if (videoIds.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoIds[_currentVideoIndex],
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          hideThumbnail: true,
          useHybridComposition: true,
        ),
      );
    }

    getHintShown().then((shown) {
      if (!shown) {
        setState(() {});
        Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {});
          }
        });
        setHintShown();
      }
    });
    if (_currentVideoIndex == 0 && widget.isStartingLesson) {
      _countdownSeconds = 5;
      _isTimerActive = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdownSeconds > 0) {
          setState(() {
            _countdownSeconds--;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isTimerActive = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (videoIds.isNotEmpty) {
      _controller.dispose();
    }
    _sessionManager.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _loadVideo(int index, {bool isNewLesson = false}) {
    if (index >= 0 && index < videoIds.length) {
      _timer?.cancel();
      setState(() {
        _countdownSeconds = 0;
        _isTimerActive = false;
        _currentVideoIndex = index;
      });
      _controller.load(videoIds[index]);
      saveLastLesson(widget.chapterNumber, widget.lessonNumber, index);

      if (index == 0 && isNewLesson) {
        _countdownSeconds = 5;
        _isTimerActive = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_countdownSeconds > 0) {
            setState(() {
              _countdownSeconds--;
            });
          } else {
            _timer?.cancel();
            setState(() {
              _isTimerActive = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'فيديوهات الدرس',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            'لا توجد فيديوهات لهذا الدرس حالياً.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.purpleAccent,
        onReady: () {
          saveLastLesson(
            widget.chapterNumber,
            widget.lessonNumber,
            _currentVideoIndex,
          );
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'الفصل ${widget.chapterNumber} - الدرس ${widget.lessonNumber}',
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.blueGrey.shade900],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.5),
                                width: 3),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                player,

// === شاشة متدرجة مع عنوان الدرس للفيديو الأول ===

                                if (_currentVideoIndex == 0)
                                  Container(
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
                                    ),
                                    child: Stack(
                                      children: [
                                        // نمط الشبكة في الخلفية
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _GridPatternPainter(),
                                          ),
                                        ),

                                        // تأثير الجسيمات في الخلفية
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _ParticlesPainter(20),
                                          ),
                                        ),

                                        // تأثير متدرج إضافي
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                center: Alignment.center,
                                                radius: 1.5,
                                                colors: [
                                                  Colors.cyanAccent
                                                      .withOpacity(0.1),
                                                  Colors.purpleAccent
                                                      .withOpacity(0.1),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // الروبوت في المنتصف مع تأثير الطفو
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // الروبوت
                                              RobotBounceAnimation(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.cyanAccent
                                                            .withOpacity(0.9),
                                                        Colors.purpleAccent
                                                            .withOpacity(0.9),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.cyanAccent
                                                            .withOpacity(0.6),
                                                        blurRadius: 30,
                                                        spreadRadius: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/robot_welcome.gif',
                                                    height: 120,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 30),

                                              // العنوان الرئيسي
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.cyanAccent
                                                        .withOpacity(0.7),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.cyanAccent
                                                          .withOpacity(0.3),
                                                      blurRadius: 15,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  chapterLessonContents[widget
                                                              .chapterNumber]?[
                                                          widget
                                                              .lessonNumber] ??
                                                      "عنوان الدرس",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 10,
                                                        color:
                                                            Colors.cyanAccent,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // رسالة تحفيزية
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Colors.purpleAccent
                                                          .withOpacity(0.5)),
                                                ),
                                                child: const Text(
                                                  "استعد لرحلة التعلم! 🚀",
                                                  style: TextStyle(
                                                    color: Colors.purpleAccent,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // أيقونات زخرفية في الزوايا
                                        Positioned(
                                          top: 20,
                                          left: 20,
                                          child: Icon(
                                              Icons.auto_awesome_rounded,
                                              color: Colors.cyanAccent
                                                  .withOpacity(0.6),
                                              size: 30),
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: Icon(
                                              Icons.lightbulb_outline_rounded,
                                              color: Colors.purpleAccent
                                                  .withOpacity(0.6),
                                              size: 30),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 20,
                                          child: Icon(Icons.school_outlined,
                                              color: Colors.cyanAccent
                                                  .withOpacity(0.6),
                                              size: 30),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          right: 20,
                                          child: Icon(
                                              Icons.rocket_launch_rounded,
                                              color: Colors.purpleAccent
                                                  .withOpacity(0.6),
                                              size: 30),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentVideoIndex > 0
                                ? () => _loadVideo(_currentVideoIndex - 1)
                                : null,
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.black, size: 20),
                            label: const Text('السابق',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 24, 255, 255),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'الفيديو ${_currentVideoIndex + 1} من ${videoIds.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentVideoIndex <
                                        videoIds.length - 1 &&
                                    (_currentVideoIndex > 0 || !_isTimerActive)
                                ? () => _loadVideo(_currentVideoIndex + 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.skip_next,
                                    color: Colors.black, size: 20),
                                const SizedBox(width: 5),
                                _currentVideoIndex == 0 &&
                                        _isTimerActive &&
                                        _countdownSeconds > 0
                                    ? Text('التالي (${_countdownSeconds})',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        textDirection: TextDirection.rtl)
                                    : const Text('التالي',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        textDirection: TextDirection.rtl),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 2. أضف دالة لاسترجاع النتائج من Firebase
Future<List<Map<String, dynamic>>> _getEssayResults(
    String userId, int chapterNumber) async {
  try {
    final snapshot = await FirebaseDatabase.instance
        .ref('users/$userId/chapter_$chapterNumber/essay_results')
        .get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> results = [];

      data.forEach((key, value) {
        results.add({
          'question_index': int.parse(key.toString()),
          'score': value['score'] ?? 0,
          'feedback': value['feedback'] ?? 'لا توجد تغذية راجعة',
          'max_score': value['max_score'] ?? 20
        });
      });

      return results;
    }
  } catch (e) {
    print('خطأ في استرجاع النتائج: $e');
  }

  return [];
}

// ===============================================
// 5. صفحة الاختبار الديناميكية - مع التعديلات
// ===============================================
class DynamicQuizPage extends StatefulWidget {
  final int chapterNumber;
  const DynamicQuizPage({super.key, required this.chapterNumber});

  @override
  State<DynamicQuizPage> createState() => _DynamicQuizPageState();
}

class _DynamicQuizPageState extends State<DynamicQuizPage> {
  final SessionManager _sessionManager = SessionManager();
  final _formKey = GlobalKey<FormState>();
  late final List<Question> questions;
  late final List<dynamic> userAnswers;
  List<TextEditingController> _essayControllers = [];
  bool _isSubmitting = false;
  List<bool> correctAnswers = []; // إضافة لتخزين الإجابات الصحيحة

  Future<void> _sendEssayToServer(String essayText, String userId,
      Question question, int chapterNumber, int questionIndex) async {
    final String apiUrl =
        'https://us-central1-essaybot-ed916.cloudfunctions.net/essay-bot';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'essay': essayText,
          'user_id': userId,
          'chapter_number': chapterNumber,
          'question_index': questionIndex,
          'question_data': {
            'correctAnswer': question.correctAnswer is List
                ? question.correctAnswer
                : [question.correctAnswer],
            'keywords': question.keywords ?? [],
          },
        }),
      );

      if (response.statusCode == 200) {
        print('المقال وبيانات السؤال تم إرسالهم بنجاح.');
        return Future.value(); // إرجاع Future مكتمل
      } else {
        print('فشل الإرسال: ${response.statusCode}');
        return Future.error('فشل الإرسال');
      }
    } catch (e) {
      print('خطأ الاتصال: $e');
      return Future.error('خطأ الاتصال');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _sessionManager.dispose();
    for (var controller in _essayControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // منطق الروبوت التحفيزي
  final List<String> robotQuizMessages = [
    'تفكير عميق! ركز في السؤال واستخدم كل ما تعلمته. 💪',
    'لا تستعجل في الإجابة، فكر جيداً قبل الاختيار. 🤔',
    'تذكر أن كل خطأ هو فرصة للتعلم. أنت قادر على حل هذا! ',
    'أنت على وشك تحقيق النجاح. ثق في قدراتك. ✨',
    'استرجع المعلومات من الدروس السابقة.🧠',
    'خذ نفساً عميقاً. أنت في بيئة داعمة للتعلم. 💯',
  ];

  late String _currentMessage;
  late Timer _timer;
  int _messageIndex = 0;

  Widget _buildEssayQuestion(Question question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          question.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _essayControllers[index],
          onChanged: (val) {
            userAnswers[index] = val;
          },
          maxLines: null,
          minLines: 8,
          expands: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText:
                'اكتب مقالك هنا (الحد الأدنى ${question.requiredWordCount} كلمة)...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.cyanAccent.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.cyanAccent.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.cyanAccent,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 10),
        Text(
          'This essay is worth 20 marks. Try to include relevant keywords.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.initializeSessionListener(context);
    });
    questions = allQuizzes[widget.chapterNumber] ?? [];
    userAnswers = List.filled(questions.length, null);
    correctAnswers = List.filled(questions.length, false); // تهيئة

    _essayControllers = List.generate(
      questions.length,
      (index) => TextEditingController(),
    );

    _currentMessage = robotQuizMessages[0];
    _startMessageTimer();
  }

  void _startMessageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeMessage();
    });
  }

  void _changeMessage() {
    _timer.cancel();
    setState(() {
      _messageIndex = (_messageIndex + 1) % robotQuizMessages.length;
      _currentMessage = robotQuizMessages[_messageIndex];
    });
    _startMessageTimer();
  }

  Future<Map<String, dynamic>> calculateScore() async {
    double totalScore = 0;
    int maxPossible = 0;
    List<Map<String, dynamic>> essayScores = [];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];

      if (userAnswer != null) {
        if (question.type == 'text_input') {
          maxPossible++;
          bool isCorrect = (userAnswer as String).trim().toLowerCase() ==
              (question.correctAnswer as String).toLowerCase();
          if (isCorrect) {
            totalScore++;
            correctAnswers[i] = true;
          }
        } else if (question.type == 'true_false' ||
            question.type == 'dropdown') {
          maxPossible++;
          bool isCorrect = userAnswer == question.correctAnswer;
          if (isCorrect) {
            totalScore++;
            correctAnswers[i] = true;
          }
        } else if (question.type == 'essay') {
          await _sendEssayToServer(
              userAnswer, 'princealaa7', question, widget.chapterNumber, i);
        }
      }
    }

    int percentage = 0;
    if (maxPossible > 0) {
      percentage = (totalScore / maxPossible * 100).round();
    }

    return {
      'percentage': percentage,
      'essayScores': essayScores,
    };
  }

  void submit() async {
    FocusScope.of(context).unfocus();

    for (int i = 0; i < questions.length; i++) {
      if (questions[i].type == 'essay') {
        userAnswers[i] = _essayControllers[i].text;
      }
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      // إرسال جميع المقالات أولاً
      List<Future> essayFutures = [];
      for (int i = 0; i < questions.length; i++) {
        if (questions[i].type == 'essay' && userAnswers[i] != null) {
          essayFutures.add(_sendEssayToServer(userAnswers[i] as String,
              'princealaa7', questions[i], widget.chapterNumber, i));
        }
      }

      // الانتظار حتى اكتمال إرسال جميع المقالات
      await Future.wait(essayFutures);

      // الانتظار قليلاً لضمان معالجة البيانات على السيرفر
      await Future.delayed(const Duration(seconds: 2));

      // استرجاع نتائج المقالات من Firebase
      List<Map<String, dynamic>> essayResults =
          await _getEssayResults('princealaa7', widget.chapterNumber);

      Map<String, dynamic> result = await calculateScore();

      setState(() {
        _isSubmitting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultPage(
            score: result['percentage'],
            totalQuestions: questions.length,
            essayScores: essayResults, // استخدام النتائج المسترجعة
            userId: 'princealaa7',
            chapterNumber: widget.chapterNumber,
            questions: questions,
            correctAnswers: correctAnswers,
            userAnswers: userAnswers,
          ),
        ),
      );

      saveChapterScore(widget.chapterNumber, result['percentage']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار الفصل ${widget.chapterNumber}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.2),
                Colors.purpleAccent.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: GestureDetector(
                    onTap: _changeMessage,
                    child: DynamicRobotAssistant(
                      key: ValueKey<int>(_messageIndex),
                      message: _currentMessage,
                      mood: RobotMood.thinking,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                switch (question.type) {
                                  case 'true_false':
                                    return _buildTrueFalseQuestion(
                                        question, index);
                                  case 'dropdown':
                                    return _buildDropdownQuestion(
                                        question, index);
                                  case 'text_input':
                                    return _buildTextInputQuestion(
                                        question, index);
                                  case 'essay':
                                    return _buildEssayQuestion(question, index);
                                  default:
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'نوع السؤال غير معروف: ${question.type}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: _isSubmitting
                                        ? [
                                            Colors.grey.shade600,
                                            Colors.grey.shade800
                                          ]
                                        : [
                                            Colors.cyanAccent,
                                            Colors.purpleAccent
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: _isSubmitting
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.cyanAccent
                                                .withOpacity(0.5),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: Colors.purpleAccent
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 24),
                                    minimumSize:
                                        const Size(double.infinity, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedOpacity(
                                        opacity: _isSubmitting ? 0 : 1,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.emoji_events_rounded,
                                                color: Colors.black,
                                                size: 28,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'عرض النتيجة',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 4,
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: AnimatedOpacity(
                                          opacity: _isSubmitting ? 1 : 0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.black),
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'جاري التصحيح...',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RobotBounceAnimation(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyanAccent.withOpacity(0.3),
                                  Colors.purpleAccent.withOpacity(0.3)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const DynamicRobotAssistant(
                              message:
                                  'جاري تصحيح إجاباتك... 🤖\nيرجى الانتظار قليلاً',
                              mood: RobotMood.correcting,
                              isLarge: true,
                              isHorizontal: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        PulseAnimation(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.cyanAccent),
                              strokeWidth: 6,
                              backgroundColor:
                                  Colors.purpleAccent.withOpacity(0.3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Column(
                          children: [
                            Text(
                              'جاري تصحيح إجاباتك ...',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'هذا قد يستغرق بضع ثوانٍ ⏳',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade300,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseQuestion(Question question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildQuestionText(question.text),
        _buildRadioListTile('صح', true, userAnswers[index],
            (val) => setState(() => userAnswers[index] = val)),
        _buildRadioListTile('خطأ', false, userAnswers[index],
            (val) => setState(() => userAnswers[index] = val)),
      ],
    );
  }

  Widget _buildDropdownQuestion(Question question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildQuestionText(question.text),
        DropdownButtonFormField<String>(
          value: userAnswers[index],
          items: question.options!.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) => setState(() => userAnswers[index] = val),
          validator: (val) => val == null ? 'الرجاء اختيار إجابة' : null,
          decoration: _inputDecoration('اختر إجابة'),
          dropdownColor: Colors.grey.shade800,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTextInputQuestion(Question question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildQuestionText(question.text),
        TextFormField(
          initialValue: userAnswers[index]?.toString() ?? '',
          onChanged: (val) => userAnswers[index] = val,
          validator: (val) =>
              val == null || val.isEmpty ? 'الرجاء كتابة إجابة' : null,
          decoration: _inputDecoration('اكتب إجابتك هنا'),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildQuestionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildRadioListTile(String title, dynamic value, dynamic groupValue,
      Function(dynamic) onChanged) {
    return RadioListTile<dynamic>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.cyanAccent,
      contentPadding: EdgeInsets.zero,
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
      ),
    );
  }
}

// ===============================================
// 6. صفحة النتائج - مع التعديلات لتمييز الأخطاء
// ===============================================
class TestResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> essayScores;
  final String userId;
  final int chapterNumber;
  final List<Question> questions;
  final List<bool> correctAnswers;
  final List<dynamic> userAnswers;

  const TestResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.essayScores,
    required this.userId,
    required this.chapterNumber,
    required this.questions,
    required this.correctAnswers,
    required this.userAnswers,
  });

  Color _getScoreColor(double score, int max) {
    double percentage = (score / max) * 100;
    if (percentage >= 75) return Colors.greenAccent;
    if (percentage >= 50) return Colors.orange;
    return Colors.redAccent;
  }

  String _getUserAnswerText(dynamic userAnswer, Question question) {
    if (userAnswer == null) return 'لم تُجب على هذا السؤال';

    if (question.type == 'true_false') {
      return userAnswer ? 'صح' : 'خطأ';
    } else {
      return userAnswer.toString();
    }
  }

  String _getCorrectAnswerText(Question question) {
    if (question.type == 'true_false') {
      return question.correctAnswer ? 'صح' : 'خطأ';
    } else if (question.type == 'dropdown' && question.options != null) {
      return question.correctAnswer.toString();
    } else {
      return question.correctAnswer.toString();
    }
  }

  void _showSolutions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'حلول الأسئلة',
            style: TextStyle(color: Colors.cyanAccent, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                if (question.type == 'essay') return const SizedBox.shrink();

                final userAnswer = userAnswers[index];
                final isCorrect = correctAnswers[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'السؤال ${index + 1}:',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        question.text,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'إجابتك: ${_getUserAnswerText(userAnswer, question)}',
                        style: TextStyle(
                          color:
                              isCorrect ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الإجابة الصحيحة: ${_getCorrectAnswerText(question)}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق',
                  style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSuccess = score >= 50;
    String robotMessage = isSuccess
        ? 'تهانينا! لقد نجحت في الاختبار 🎉'
        : 'للأسف، لم تحصل على الدرجة الكافية ';
    RobotMood robotMood = isSuccess ? RobotMood.happy : RobotMood.sad;
    questions.any((q) => q.type == 'essay');

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('نتيجة الاختبار', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black87,
              isSuccess
                  ? Colors.green.shade900.withOpacity(0.8)
                  : Colors.red.shade900.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DynamicRobotAssistant(
                        message: robotMessage,
                        mood: robotMood,
                        isLarge: true,
                        isHorizontal: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'نتيجة الاختبار:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$score/100',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _getScoreColor(score.toDouble(), 100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withOpacity(0.6),
                              Colors.deepPurpleAccent.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DynamicQuizPage(
                                  chapterNumber: chapterNumber,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 20),
                              SizedBox(width: 8),
                              Text('إعادة', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withOpacity(0.6),
                              Colors.deepPurpleAccent.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showSolutions(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lightbulb_outline, size: 20),
                              SizedBox(width: 8),
                              Text(' الحلول', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withOpacity(0.6),
                              Colors.deepPurpleAccent.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LessonsHomePage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 20),
                              SizedBox(width: 8),
                              Text('العودة', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
