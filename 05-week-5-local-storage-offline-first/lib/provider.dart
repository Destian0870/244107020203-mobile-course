import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/note.dart';
import 'data/repositories/note_repository.dart';

// Provider untuk NoteRepository
final noteRepositoryProvider = Provider((ref) => NoteRepository());

// Provider untuk mengambil daftar catatan (Notes)
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  return await repository.fetchNotes();
});