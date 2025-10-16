import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // التحقق من عدم تهيئة Firebase مسبقاً
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
    } else {
        print("ℹ️ Firebase already configured")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // إعداد الإشعارات
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
