// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_vault/darts/database_helpers/sunday_database_helper.dart';
import 'package:memo_vault/darts/notes/sunday/read/sundaynote_details_screen.dart';
import 'package:memo_vault/darts/notes/sunday/add/sundaynote_add_screen.dart';

class SundayScreen extends StatefulWidget {
  const SundayScreen({super.key});

  @override
  _SundayScreenState createState() => _SundayScreenState();
}

class _SundayScreenState extends State<SundayScreen> {
  late Future<List<Map<String, dynamic>>> _notes;
  String? _selectedMonth;
  String? _selectedYear;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateFormat('MM').format(now);
    _selectedYear = now.year.toString();
    _filterNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = DatabaseHelper().getsundayNotes();
    });
  }

  void _filterNotes() {
    setState(() {
      _notes = _getFilteredNotes();
    });
  }

  Future<List<Map<String, dynamic>>> _getFilteredNotes() async {
    final db = await DatabaseHelper().database;

    String? monthFilter = _selectedMonth;
    String? yearFilter = _selectedYear;
    String searchQuery = _searchController.text.trim();

    String whereClause = '';
    List<String> whereArgs = [];

    if (monthFilter != null) {
      whereClause += 'strftime("%m", date_created) = ?';
      whereArgs.add(monthFilter.padLeft(2, '0')); // Ensure 2 digits
    }

    if (yearFilter != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'strftime("%Y", date_created) = ?';
      whereArgs.add(yearFilter);
    }

    if (searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'title LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'sunday',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'pin DESC, id DESC', // Pinned notes first, then by id
    );
  }

  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditScreen()),
    ).then((_) {
      // Reload notes after adding a new one
      _loadNotes();
    });
  }

  Future<void> _showOptionsDialog(int noteId, bool isPinned) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030), // Dialog background color
          title: const Text(
            'Note Options',
            style: TextStyle(color: Colors.white), // Title text color
          ),
          content: const Text(
            'Choose an action for this note:',
            style: TextStyle(color: Colors.white), // Content text color
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                isPinned ? 'Unpin from Top' : 'Pin to Top',
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseHelper()
                    .updateSundayNotePinned(noteId, !isPinned);
                _filterNotes(); // Refresh the list
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(255, 240, 47, 47)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(noteId);
              },
            ),
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 194, 194, 195))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(int noteId) async {
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
      await DatabaseHelper().deletesundayNoteById(noteId);
      _filterNotes(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = List.generate(
        12, (index) => DateFormat('MM').format(DateTime(0, index + 1)));
    List<String> years =
        List.generate(10, (index) => (DateTime.now().year - index).toString());

    return Scaffold(
      backgroundColor: const Color(0xFF454545),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: const Text(
          'Sunday Service Notes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by Title',
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Color(0xFF303030),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              _filterNotes();
            },
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    hint: const Text(
                      'Select Month',
                      style: TextStyle(color: Colors.white),
                    ),
                    items: months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          DateFormat('MMMM')
                              .format(DateTime(0, int.parse(month))),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                      _filterNotes();
                    },
                    dropdownColor: const Color(0xFF303030),
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: const Color(0xFF454545),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    hint: const Text(
                      'Select Year',
                      style: TextStyle(color: Colors.white),
                    ),
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(
                          year,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                      _filterNotes();
                    },
                    dropdownColor: const Color(0xFF303030),
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: const Color(0xFF454545),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notes found'));
                } else {
                  final notes = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final noteTitle = note['title'];
                      final noteId = note['id'];
                      final isPinned = note['pin'] == 1;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteDetailScreen(note: note),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showOptionsDialog(noteId, isPinned);
                        },
                        child: Card(
                          color: const Color(0xFF303030),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    noteTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          25, // Adjust the font size as needed
                                      fontWeight: FontWeight
                                          .bold, // Makes the text bold
                                    ),
                                  ),
                                ),
                              ),
                              if (isPinned)
                                const Positioned(
                                  top: 8.0,
                                  right: 8.0,
                                  child: Icon(
                                    Icons.push_pin,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: const Color(0xFF303030),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
