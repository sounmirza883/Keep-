# Slate — Claude Code Project Context

## Product
Slate is a cross-platform offline-first workspace (notes + tasks + documents).
Flutter + Supabase + PowerSync + on-device AI. No cloud AI APIs.
Targets: Android, iOS, macOS, Windows, Web, Linux.

## Architecture Rules
- STRICTLY follow MVVM: Views → ViewModels (ChangeNotifier) → Repositories → Services
- Domain models MUST use freezed. Never use raw Maps for domain data.
- State management: Riverpod 2.x code generation (@riverpod annotations). No manual StateNotifierProvider.
- Database: Drift (SQLite). All queries via typed DAOs, never raw SQL in UI layer.
- Sync: PowerSync. Never write directly to Supabase from the UI layer — always write to Drift first.
- Navigation: go_router with typed routes (GoRouteData). No Navigator.push directly.
- Dependency injection: Riverpod providers. No GetIt or service_locator.

## Platform AI Rules
- Native AI accessed ONLY through NativeAiService (lib/data/services/native_ai_service.dart)
- ALWAYS check isAvailable before calling AI methods
- NEVER add internet AI API keys to this project
- Platform channel name: "slate/native_ai"
- iOS/macOS: FoundationModels framework (iOS 26+, macOS 26+)
- Android: ML Kit GenAI (Gemini Nano via AICore)
- Windows: Windows AI Foundry (Phi-4-Silicon) — WinRT bindings in windows/runner/

## Naming Conventions
- Files: snake_case.dart
- Classes: PascalCase
- Providers: camelCaseProvider (e.g., noteRepositoryProvider)
- ViewModels: NoteEditorViewModel, NoteListViewModel
- Repositories: NoteRepository, TaskRepository

## Key Environment Variables
- SUPABASE_URL, SUPABASE_ANON_KEY → .env (never commit)
- POWERSYNC_URL → .env
- All read via Env class (lib/core/env.dart using envied package)

## Testing Mandates
- All Repository and UseCase classes MUST have unit tests
- All ViewModels MUST have unit tests with mocked repositories
- Integration tests (Patrol) required for: auth flow, create note, create task, offline/online sync

## Code Generation
After any change to freezed models or Drift schema:
  dart run build_runner build --delete-conflicting-outputs

## Do NOT
- Do NOT use BuildContext in any ViewModel or Repository
- Do NOT use setState in screens (use Riverpod Consumer/ConsumerWidget)
- Do NOT hardcode user IDs — always read from auth provider
- Do NOT write to Supabase directly — use PowerSync upload queue
- Do NOT add any cloud LLM API (OpenAI, Anthropic, Gemini API) to this project
