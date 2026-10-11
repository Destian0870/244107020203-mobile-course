import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteTile({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        note.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: note.dirty
          ? const Chip(
              label: Text('Belum tersinkron', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.orangeAccent,
            )
          : null,
      onTap: onTap,
    );
  }
}