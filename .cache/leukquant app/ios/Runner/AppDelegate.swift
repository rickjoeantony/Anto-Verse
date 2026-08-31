import Flutter
import UIKit
import UserNotifications
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.leukquant.app/audio_alerts"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Configure Lock-Screen & High-Priority User Notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      var authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      if #available(iOS 12.0, *) {
        authOptions.insert(.criticalAlert)
      }
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
        if let error = error {
          NSLog("[LeukQuant] Notification authorization error: %@", error.localizedDescription)
        }
      }
    }

    application.registerForRemoteNotifications()
    application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

    // Method Channel bridge for iOS audio and high-priority notifications
    if let controller = window?.rootViewController as? FlutterViewController {
      let audioChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
      audioChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard let self = self else {
          result(FlutterError(code: "DEALLOCATED", message: "AppDelegate deallocated", details: nil))
          return
        }

        switch call.method {
        case "playAlertTone":
          let toneType = (call.arguments as? [String: Any])?["type"] as? String ?? "cyberRadar"
          self.playNativeAlertTone(type: toneType)
          result(true)
        case "postAlertNotification":
          guard let args = call.arguments as? [String: Any],
                let title = args["title"] as? String,
                let body = args["body"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing title or body", details: nil))
            return
          }
          let id = args["id"] as? Int ?? 99991
          let isCritical = args["isCritical"] as? Bool ?? true
          self.postNativeIOSNotification(id: id, title: title, body: body, isCritical: isCritical)
          result(true)
        case "openNotificationSettings":
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Ensure notifications are presented as banners and sounds even when app is active, closed, or locked
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound, .list])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  private func playNativeAlertTone(type: String) {
    switch type.lowercased() {
    case "cyberradar":
      AudioServicesPlayAlertSound(1005) // SMS Received / Alarm chime
      AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    case "tacticalpulse":
      AudioServicesPlayAlertSound(1013) // Pulse Alert tone
      AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    case "enterpriseping":
      AudioServicesPlayAlertSound(1000) // Clean discrete ping
      AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    default:
      AudioServicesPlayAlertSound(1005)
      AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
  }

  private func postNativeIOSNotification(id: Int, title: String, body: String, isCritical: Bool) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body

    if isCritical {
      if #available(iOS 12.0, *) {
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
      } else {
        content.sound = UNNotificationSound.default
      }
    } else {
      content.sound = UNNotificationSound.default
    }

    if #available(iOS 15.0, *) {
      content.interruptionLevel = isCritical ? .critical : .timeSensitive
    }

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: "leukquant_alert_\(id)", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        NSLog("[LeukQuant] Failed to add notification: %@", error.localizedDescription)
      }
    }
  }
}