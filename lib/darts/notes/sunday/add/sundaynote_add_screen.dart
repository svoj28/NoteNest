// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:memo_vault/darts/database_helpers/sunday_database_helper.dart';
import 'dart:convert';

class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({super.key});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  final List<String> _imagePaths = [];
  String? _audioPath;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  void _deleteImage(String imagePath) {
    setState(() {
      _imagePaths.remove(imagePath);
    });
  }

  void _showDeleteDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 194, 194, 195))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(color: Color.fromARGB(255, 240, 47, 47))),
              onPressed: () {
                _deleteImage(imagePath);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    await DatabaseHelper().insertsundayNote(
      title,
      content,
      DateTime.now().toIso8601String(),
      _imagePaths.isNotEmpty ? _imagePaths.join(',') : null,
      _audioPath,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF454545),
      appBar: AppBar(
        title: const Text(
          'Sunday Notes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF303030),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
            tooltip: 'Add Image',
          ),
          IconButton(
            icon: const Icon(Icons.audiotrack),
            onPressed: _pickAudio,
            tooltip: 'Add Audio',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: QuillSimpleToolbar(
                      controller: _controller,
                      configurations: QuillSimpleToolbarConfigurations(
                        multiRowsDisplay: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        color: Colors.white,
                        dialogTheme: QuillDialogTheme(
                          dialogBackgroundColor: Colors.grey[800],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF303030),
                        ),
                        toolbarSize: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: QuillEditor.basic(
                        controller: _controller,
                        configurations: const QuillEditorConfigurations(
                          placeholder:
                              'Share your thoughts about the Sunday Service...',
                        ),
                        focusNode: FocusNode(),
                        scrollController: ScrollController(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_imagePaths.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    final imagePath = _imagePaths[index];
                    return GestureDetector(
                      onLongPress: () => _showDeleteDialog(imagePath),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Text(''),
            const SizedBox(height: 20),
            if (_audioPath != null)
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: Text(_audioPath!.split('/').last),
              ),
            if (_audioPath == null) const Text(''),
          ],
        ),
      ),
    );
  }
}
