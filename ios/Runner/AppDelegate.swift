import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // تأخير تهيئة Firebase قليلاً
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // تأخير الإرجاع قليلاً للتأكد من اكتمال التهيئة
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // أي إعدادات إضافية
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
