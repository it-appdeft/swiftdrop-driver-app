import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    GeneratedPluginRegistrant.register(with: self)
    setupNativeChannel()
    return result
  }

  private func setupNativeChannel() {
    guard let messenger = self.registrar(forPlugin: "SwiftDropNative")?.messenger() else { return }
    FlutterMethodChannel(name: "com.swiftdrop/native", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard call.method == "dismissPresented" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let root = self?.window?.rootViewController,
              root.presentedViewController != nil else {
          result(nil)
          return
        }
        root.dismiss(animated: false) { result(nil) }
      }
  }
}
