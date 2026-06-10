import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// On-device AI bridge for iOS/macOS using Apple Foundation Models.
/// All inference stays on device; no network calls allowed here.
@available(iOS 26.0, macOS 26.0, *)
class SlateNativeAI {

    // MARK: - Availability
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        return SystemLanguageModel.default.availability == .available
        #else
        return false
        #endif
    }

    #if canImport(FoundationModels)

    // MARK: - Summarize
    static func summarize(text: String) async throws -> String {
        let session = LanguageModelSession(
            instructions: "Summarize the following note in 2-3 concise sentences. Return only the summary."
        )
        let response = try await session.respond(to: text)
        return response.content
    }

    // MARK: - Auto-tag (structured output via @Generable)
    @Generable
    struct TagResult {
        @Guide(description: "Array of 1-5 relevant topic tags, lowercase, no spaces")
        var tags: [String]
    }

    static func autoTag(text: String) async throws -> [String] {
        let session = LanguageModelSession(
            instructions: "Extract 1-5 relevant topic tags from the text. Return only lowercase tags."
        )
        let result = try await session.respond(to: text, generating: TagResult.self)
        return result.content.tags
    }

    // MARK: - Smart Search (semantic reranking)
    static func smartSearch(query: String, documents: [String]) async throws -> String {
        let joined = documents.enumerated()
            .map { "[\($0.offset)]: \($0.element)" }
            .joined(separator: "\n")
        let session = LanguageModelSession(
            instructions: "Given a search query, return the index of the most relevant document. Reply with only the number."
        )
        let response = try await session.respond(to: "Query: \(query)\n\nDocuments:\n\(joined)")
        return response.content.trimmingCharacters(in: .whitespaces)
    }

    #endif

    // MARK: - Child Safety: Declared Age Range
    // Requires the com.apple.developer.family-controls entitlement and
    // Family Sharing set up on the device. Returns "child" (<13),
    // "teen" (13-17), "adult" (18+), or "unknown" when unavailable.
    static func getDeclaredAgeRange() -> String {
        // Production: query DeclaredAgeRange from FamilyControls.
        return "unknown"
    }

    // MARK: - Sensitive Content Analysis
    // Production: SCSensitivityAnalyzer from SensitiveContentAnalysis.
    static func checkSensitiveContent(text: String) async -> Bool {
        return false
    }
}
