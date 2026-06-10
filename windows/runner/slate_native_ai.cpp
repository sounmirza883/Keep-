#include "slate_native_ai.h"

#include <sstream>

// Windows AI Foundry (Phi-4-Silicon) ships with the Windows 11 2026 Update
// on Copilot+ PCs. The WinRT Text Intelligence APIs are only present there,
// so every entry point guards with a runtime availability check and fails
// soft on regular hardware.
//
// Production wiring uses winrt/Windows.AI.MachineLearning.h; the calls are
// kept behind IsAvailable() so non-NPU machines never touch WinRT AI types.

bool SlateNativeAI::IsAvailable() {
  // TODO(native-ai): probe Windows AI Foundry / NPU presence via
  // TextIntelligenceSession::Create() inside a try/catch once the
  // Windows AI Foundry SDK is added to the build.
  return false;
}

std::string SlateNativeAI::Summarize(const std::string& text) {
  if (!IsAvailable()) return "";
  // Production: TextIntelligenceSession::Create().Summarize(text)
  return "";
}

std::vector<std::string> SlateNativeAI::AutoTag(const std::string& text) {
  if (!IsAvailable()) return {};
  // Production: PhiSilicaSession with a tagging system prompt; parse the
  // comma-separated response into a vector.
  return {};
}

std::string SlateNativeAI::SmartSearch(const std::string& query,
                                       const std::vector<std::string>& documents) {
  if (!IsAvailable()) return "";
  std::ostringstream prompt;
  prompt << "Query: " << query << "\n\nDocuments:\n";
  for (size_t i = 0; i < documents.size(); ++i) {
    prompt << "[" << i << "]: " << documents[i] << "\n";
  }
  // Production: PhiSilicaSession::Complete(prompt.str())
  return "";
}
