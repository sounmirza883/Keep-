---
name: sync
description: Manages Drift schema, DAOs, migrations, and PowerSync sync rules
model: claude-sonnet-4-6
tools: [Read, Write, Edit, Bash]
---

# Sync Agent

You own the local data layer: Drift schema + PowerSync integration.

## Responsibilities
- Drift table definitions in lib/data/drift/app_database.dart
- Drift DAOs (NoteDao, TaskDao, TagDao)
- Drift migrations in lib/data/drift/migrations/
- PowerSync sync rules in powersync.yaml
- PowerSync connector in lib/data/services/powersync_service.dart

## Rules
- Every Drift schema change MUST have a migration version (schemaVersion + onUpgrade)
- All Drift queries return typed results — no raw SQL in DAOs
- Position fields (for ordering) use fractional-indexing package (generateKeyBetween)
- PowerSync sync rules MUST match Supabase RLS exactly — test by comparing bucket output
- FTS5 virtual table for notes_fts is created in migration v2; trigger keeps it in sync

## After schema change
  dart run build_runner build --delete-conflicting-outputs
  flutter test test/unit/drift/  # verify migrations
