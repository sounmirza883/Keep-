import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let aiChannel = FlutterMethodChannel(
      name: "slate/native_ai",
      binaryMessenger: controller.binaryMessenger
    )

    aiChannel.setMethodCallHandler { call, result in
      guard #available(iOS 26.0, *) else {
        // Older OS: report unavailable, never crash.
        if call.method == "isAvailable" {
          result(false)
        } else {
          result(FlutterMethodNotImplemented)
        }
        return
      }

      Task {
        switch call.method {
        case "isAvailable":
          result(SlateNativeAI.isAvailable)

        case "summarize":
          guard let args = call.arguments as? [String: Any],
                let text = args["text"] as? String else {
            result(FlutterError(code: "ARGS", message: "text required", details: nil))
            return
          }
          do {
            #if canImport(FoundationModels)
            let summary = try await SlateNativeAI.summarize(text: text)
            result(summary)
            #else
            result(nil)
            #endif
          } catch {
            result(FlutterError(code: "AI_ERROR", message: error.localizedDescription, details: nil))
          }

        case "autoTag":
          guard let args = call.arguments as? [String: Any],
                let text = args["text"] as? String else {
            result(FlutterError(code: "ARGS", message: "text required", details: nil))
            return
          }
          do {
            #if canImport(FoundationModels)
            let tags = try await SlateNativeAI.autoTag(text: text)
            result(tags)
            #else
            result([String]())
            #endif
          } catch {
            result(FlutterError(code: "AI_ERROR", message: error.localizedDescription, details: nil))
          }

        case "smartSearch":
          guard let args = call.arguments as? [String: Any],
                let query = args["query"] as? String,
                let documents = args["documents"] as? [String] else {
            result(FlutterError(code: "ARGS", message: "query and documents required", details: nil))
            return
          }
          do {
            #if canImport(FoundationModels)
            let index = try await SlateNativeAI.smartSearch(query: query, documents: documents)
            result(index)
            #else
            result(nil)
            #endif
          } catch {
            result(FlutterError(code: "AI_ERROR", message: error.localizedDescription, details: nil))
          }

        case "getDeclaredAgeRange":
          result(SlateNativeAI.getDeclaredAgeRange())

        case "checkSensitiveContent":
          let args = call.arguments as? [String: Any]
          let text = args?["text"] as? String ?? ""
          let flagged = await SlateNativeAI.checkSensitiveContent(text: text)
          result(flagged)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
