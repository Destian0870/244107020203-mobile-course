import 'repositories/note_repository.dart';

// Fungsi syncNotes dipindah ke sini sesuai instruksi refactoring
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  
  // Simulasi upload ke server
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}