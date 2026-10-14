import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var privacyOverlayView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Listen for screen recording / mirroring changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func screenCaptureChanged() {
    if UIScreen.main.isCaptured {
      applyPrivacyOverlay()
    } else {
      removePrivacyOverlay()
    }
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    applyPrivacyOverlay()
    super.applicationWillResignActive(application)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    if !UIScreen.main.isCaptured {
      removePrivacyOverlay()
    }
  }

  private func applyPrivacyOverlay() {
    guard privacyOverlayView == nil, let window = window else { return }
    let blur = UIBlurEffect(style: .light)
    let effectView = UIVisualEffectView(effect: blur)
    effectView.frame = window.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(effectView)
    privacyOverlayView = effectView
  }

  private func removePrivacyOverlay() {
    privacyOverlayView?.removeFromSuperview()
    privacyOverlayView = nil
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
