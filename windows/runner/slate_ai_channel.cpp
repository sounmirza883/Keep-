// Method channel registration for "slate/native_ai".
// Call RegisterSlateAiChannel(...) from FlutterWindow::OnCreate after the
// Flutter controller's engine is ready.

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>

#include "slate_native_ai.h"

void RegisterSlateAiChannel(flutter::BinaryMessenger* messenger) {
  static auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "slate/native_ai",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const auto& method = call.method_name();

        if (method == "isAvailable") {
          result->Success(flutter::EncodableValue(SlateNativeAI::IsAvailable()));
          return;
        }

        const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());

        if (method == "summarize" || method == "autoTag") {
          if (!args) {
            result->Error("ARGS", "text required");
            return;
          }
          auto it = args->find(flutter::EncodableValue("text"));
          if (it == args->end()) {
            result->Error("ARGS", "text required");
            return;
          }
          const auto& text = std::get<std::string>(it->second);
          if (method == "summarize") {
            result->Success(flutter::EncodableValue(SlateNativeAI::Summarize(text)));
          } else {
            flutter::EncodableList tags;
            for (const auto& tag : SlateNativeAI::AutoTag(text)) {
              tags.push_back(flutter::EncodableValue(tag));
            }
            result->Success(flutter::EncodableValue(tags));
          }
          return;
        }

        if (method == "smartSearch") {
          if (!args) {
            result->Error("ARGS", "query and documents required");
            return;
          }
          const auto& query = std::get<std::string>(
              args->at(flutter::EncodableValue("query")));
          const auto& docsValue = std::get<flutter::EncodableList>(
              args->at(flutter::EncodableValue("documents")));
          std::vector<std::string> documents;
          for (const auto& d : docsValue) {
            documents.push_back(std::get<std::string>(d));
          }
          result->Success(flutter::EncodableValue(
              SlateNativeAI::SmartSearch(query, documents)));
          return;
        }

        // Apple-only child safety APIs — graceful defaults on Windows
        if (method == "getDeclaredAgeRange") {
          result->Success(flutter::EncodableValue("unknown"));
          return;
        }
        if (method == "checkSensitiveContent") {
          result->Success(flutter::EncodableValue(false));
          return;
        }

        result->NotImplemented();
      });
}
