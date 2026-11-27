import Flutter
import UIKit
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

class SceneDelegate: FlutterSceneDelegate {
  private var didRequestTrackingAuthorization = false

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    requestTrackingAuthorizationIfNeeded()
  }

  /// Requests iOS App Tracking Transparency (ATT) once after launch so Google AdMob
  /// can deliver higher-eCPM personalized ads when granted (still works non-personalized if denied).
  private func requestTrackingAuthorizationIfNeeded() {
    guard !didRequestTrackingAuthorization else { return }
    didRequestTrackingAuthorization = true
    #if canImport(AppTrackingTransparency)
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
          ATTrackingManager.requestTrackingAuthorization { _ in }
        }
      }
    }
    #endif
  }
}
