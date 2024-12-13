import 'package:flutter/material.dart';
import 'package:notes/screens/edit_note_screen.dart';
import 'package:notes/utils/db_helper.dart';
import 'package:notes/models/note.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotesHome(),
    );
  }
}

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final _dbHelper = DBHelper.instance;
  late Future<List<Note>> _notes;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notes = _dbHelper.fetchNotes();
    });
  }

  void _addNewNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditNoteScreen(),
      ),
    );

    if (result == true) {
      _refreshNotes();
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );

    if (result == true) {
      _refreshNotes();
    }
  }

  void _deleteNoteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: const Text('Удалить заметку'),
        ),
        content: const Text('Вы уверены, что хотите удалить эту заметку?',
        style: TextStyle(
        fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteNoteById(id);
              _refreshNotes();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Создайте заметку'));
          } else {
  return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
  final note = snapshot.data![index];
  return ListTile(
  title: Text(
    note.title,
    style: const TextStyle(
      fontSize: 18,  
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: Text(
    note.content,
    style: const TextStyle(
      fontSize: 16,  
    ),
  ),
  onTap: () => _editNote(note),
  trailing: IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    onPressed: () => _deleteNoteConfirm(note.id!),
    ),
    );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
