import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/services/native_ai_service.dart';

/// Text search (always available offline) with optional on-device AI
/// reranking: the model picks the most relevant hit and it is promoted
/// to the top of the results.
class SmartSearchUseCase {
  SmartSearchUseCase({
    required NoteRepository notes,
    required NativeAiService ai,
  })  : _notes = notes,
        _ai = ai;

  final NoteRepository _notes;
  final NativeAiService _ai;

  static const _rerankLimit = 10;

  Future<List<Note>> call(String userId, String query) async {
    final results = await _notes.searchNotes(userId, query);
    if (results.length < 2) return results;

    final candidates = results.take(_rerankLimit).toList();
    final docs = candidates
        .map((n) => '${n.title}\n${n.content}'.substring(
            0, '${n.title}\n${n.content}'.length.clamp(0, 500)))
        .toList();

    final response = await _ai.smartSearch(query, docs);
    final best = int.tryParse(response?.trim() ?? '');
    if (best == null || best < 0 || best >= candidates.length || best == 0) {
      return results;
    }

    final promoted = candidates[best];
    return [promoted, ...results.where((n) => n.id != promoted.id)];
  }
}
