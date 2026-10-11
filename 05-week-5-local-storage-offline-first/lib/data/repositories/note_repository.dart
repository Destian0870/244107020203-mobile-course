import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }

  Future<List<Map<String, dynamic>>> readCachedPosts() async {
    final db = await _openDb();
    return await db.query('cached_posts', orderBy: 'cached_at DESC');
  }

  void refreshPostsInBackground() async {
    // Simulasi background fetch dari API lalu simpan ke tabel cached_posts
  }

  Future<List<Map<String, dynamic>>> loadPostsCacheFirst() async {
    final cached = await readCachedPosts(); // dari tabel cached_posts
    // 1. Segera kembalikan cache agar UI tidak blank saat offline.[cite: 9]
    // 2. Di background: fetch Dio -> simpan ke cached_posts -> invalidate provider.[cite: 9]
    refreshPostsInBackground();
    return cached;
  }

  Future<int> syncNotes() async {
    final dirtyCount = await countDirty();
    if (dirtyCount == 0) return 0;
    
    // Simulasi upload ke server dengan delay 1 detik
    await Future.delayed(const Duration(seconds: 1));
    
    // Jika server merespons sukses, tandai lokal kembali bersih
    await markAllSynced();
    return dirtyCount;
  }
}