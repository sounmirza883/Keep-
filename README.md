# Slate

Cross-platform, offline-first, privacy-first workspace for notes, tasks, and documents.

**Stack:** Flutter · Supabase · PowerSync · Drift · Riverpod · on-device AI (Foundation Models / Gemini Nano / Phi-4-Silicon)

## Key principles

- **Offline-first** — all writes go to the local Drift (SQLite) database instantly; PowerSync syncs to Supabase in the background.
- **On-device AI only** — summarization, auto-tagging, and semantic search run via platform-native AI APIs. No cloud LLM APIs, ever.
- **Single codebase** — Android, iOS, macOS, Windows, Web, Linux.

## Getting started

1. Install Flutter 3.29+ and Dart 3.7+.
2. Copy `.env.example` to `.env` and fill in your Supabase + PowerSync credentials.
3. Run the platform scaffolding (once): `flutter create . --org com.slate`
4. Install dependencies: `flutter pub get`
5. Generate code: `dart run build_runner build --delete-conflicting-outputs`
6. Apply the Supabase schema: run `supabase/migrations/*.sql` in the Supabase SQL editor.
7. Deploy `powersync.yaml` sync rules to your PowerSync instance.
8. Run: `flutter run`

## Project layout

```
lib/
├── core/            # Env config
├── data/
│   ├── drift/       # Local SQLite schema + DAOs
│   ├── models/      # freezed domain models
│   ├── repositories/
│   ├── services/    # PowerSync connector, NativeAiService
│   └── providers.dart
├── domain/use_cases/
└── ui/
    ├── core/        # SlateTheme, shared widgets
    └── features/    # auth, notes, tasks, tags, search, settings
```

See `.claude/CLAUDE.md` for architecture rules and `slateprd.md`-derived phase plan.

## Testing

```
flutter test --coverage
```

Unit tests live in `test/unit/`, widget tests in `test/widget/`, Patrol integration tests in `integration_test/`.
