// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:memo_vault/darts/database_helpers/sunday_database_helper.dart';
import 'package:memo_vault/darts/notes/sunday/edit/sundaynote_edit_screen.dart';
import 'dart:convert';
import 'dart:io';

class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onNoteUpdated;

  const NoteDetailScreen({
    required this.note,
    this.onNoteUpdated,
    super.key,
  });

  Future<void> _showDeleteConfirmation(BuildContext context, int noteId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030), // Dialog background color
          title: const Text(
            'Delete Note',
            style: TextStyle(color: Colors.white), // Title text color
          ),
          content: const Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(color: Colors.white), // Content text color
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 194, 194, 195))),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(color: Color.fromARGB(255, 240, 47, 47))),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      final db = DatabaseHelper();
      await db.deletesundayNoteById(noteId);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    quill.QuillController _controller = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(note['content'])),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF303030), // Page background color
        appBar: AppBar(
          backgroundColor: const Color(0xFF232323), // AppBar background color
          title:
              Text(note['title'], style: const TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                     builder: (context) => EditNoteScreen(note: note, onNoteUpdated: onNoteUpdated),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFBB2124)),
              onPressed: () async {
                await _showDeleteConfirmation(context, note['id']);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Text'),
              Tab(text: 'Image'),
              Tab(text: 'Audio'),
            ],
            labelColor: Colors.white, // Tab label color
            unselectedLabelColor:
                Color(0xFFB0B0B0), // Unselected tab label color
            indicatorColor: Colors.white, // Tab indicator color
          ),
        ),
        body: TabBarView(
          children: [
            // Text Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: quill.QuillEditor.basic(
                configurations: const QuillEditorConfigurations(
                    placeholder:
                        'Share your thoughts about the Sunday Service...',
                    showCursor: false),
                controller: _controller,
                focusNode: FocusNode(),
                // Ensure the editor is non-interactive
              ),
            ),
            // Image Tab
            if (note['image_path'] != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(File(note['image_path'])),
              )
            else
              const Center(
                  child: Text('No Image Available',
                      style: TextStyle(color: Colors.white))),
            // Audio Tab
            if (note['audio_path'] != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Audio file: ${note['audio_path']}',
                        style: const TextStyle(color: Colors.white)),
                    // You can add audio playback widget here
                  ],
                ),
              )
            else
              const Center(
                  child: Text('No Audio Available',
                      style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
