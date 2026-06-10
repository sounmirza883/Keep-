#ifndef RUNNER_SLATE_NATIVE_AI_H_
#define RUNNER_SLATE_NATIVE_AI_H_

#include <string>
#include <vector>

// On-device AI bridge for Windows Copilot+ PCs (Phi-4-Silicon via
// Windows AI Foundry). All methods fail soft: empty results, no throws,
// no network calls.
class SlateNativeAI {
 public:
  static bool IsAvailable();
  static std::string Summarize(const std::string& text);
  static std::vector<std::string> AutoTag(const std::string& text);
  static std::string SmartSearch(const std::string& query,
                                 const std::vector<std::string>& documents);
};

#endif  // RUNNER_SLATE_NATIVE_AI_H_
