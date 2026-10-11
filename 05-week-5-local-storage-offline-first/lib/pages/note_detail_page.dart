import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider.dart';
import '../data/local/note.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final int noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  Note? _note;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final repo = ref.read(noteRepositoryProvider);
    final notes = await repo.fetchNotes();
    try {
      final found = notes.firstWhere((n) => n.id == widget.noteId);
      setState(() {
        _note = found;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Catatan')),
        body: const Center(child: Text('Catatan tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_note!.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _note!.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _note!.body,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Chip(
              label: Text(_note!.dirty ? 'Status: Belum tersinkron' : 'Status: Tersinkron'),
              backgroundColor: _note!.dirty ? Colors.orangeAccent : Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}