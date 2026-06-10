# Changelog

## 1.0.0 (unreleased)

### Added
- **Notes**: create, edit, pin, soft-delete with 30-day retention; auto-save every 3 seconds
- **Tasks**: list view grouped by Today / Upcoming / No date; Kanban board with drag-and-drop ordering (fractional indexing); priority + due dates; optional link to a note
- **Tags**: per-user unique tags with note tagging junction
- **Offline-first sync**: all writes hit local SQLite instantly; PowerSync syncs to Supabase in the background with last-write-wins conflict resolution; sync status indicator (synced / pending / offline)
- **Auth**: email/password, magic link, Google OAuth, Apple Sign In via Supabase Auth
- **On-device AI** (no cloud APIs): summarize and auto-tag notes, semantic search reranking
  - iOS/macOS 26+: Apple Foundation Models
  - Android (AICore devices): ML Kit GenAI / Gemini Nano
  - Windows Copilot+ (scaffolded): Phi-4-Silicon via Windows AI Foundry
  - Graceful fallback everywhere else
- **Search**: debounced full-text search with optional AI reranking
- **Attachments**: upload to Supabase Storage with offline local cache
- **Child safety scaffolding** (iOS 26+): Declared Age Range + Sensitive Content Analysis hooks
- **CI/CD**: GitHub Actions test + release pipelines; Codemagic multi-platform build matrix
- Sentry crash reporting (opt-in via SENTRY_DSN dart-define)
