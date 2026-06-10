import 'package:powersync/powersync.dart';

/// PowerSync-managed local schema. Mirrors the Supabase Postgres schema
/// (supabase/migrations/) and the sync rules in powersync.yaml.
const Schema appSchema = Schema([
  Table('notes', [
    Column.text('user_id'),
    Column.text('title'),
    Column.text('content'),
    Column.text('content_type'),
    Column.integer('is_pinned'),
    Column.integer('is_deleted'),
    Column.text('deleted_at'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('notes_user', [IndexedColumn('user_id')]),
    Index('notes_updated', [IndexedColumn('updated_at')]),
  ]),
  Table('tasks', [
    Column.text('user_id'),
    Column.text('note_id'),
    Column.text('title'),
    Column.text('description'),
    Column.text('status'),
    Column.text('priority'),
    Column.text('position'),
    Column.text('due_date'),
    Column.integer('is_deleted'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('tasks_user', [IndexedColumn('user_id')]),
    Index('tasks_status', [IndexedColumn('status')]),
  ]),
  Table('tags', [
    Column.text('user_id'),
    Column.text('name'),
    Column.text('color_hex'),
    Column.text('created_at'),
  ]),
  Table('note_tags', [
    Column.text('note_id'),
    Column.text('tag_id'),
  ]),
  Table('attachments', [
    Column.text('note_id'),
    Column.text('user_id'),
    Column.text('name'),
    Column.text('storage_path'),
    Column.text('mime_type'),
    Column.integer('size_bytes'),
    Column.text('local_path'),
    Column.integer('sync_status'),
    Column.text('created_at'),
  ]),
]);
