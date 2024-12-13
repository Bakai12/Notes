import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/note.dart';
import 'package:notes/utils/db_helper.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  // ignore: library_private_types_in_public_api
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late DBHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper.instance;

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void _saveNote() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните название и содержание заметки.',
        style: TextStyle(
        fontSize: 17),
        )),
      );
      return;
    }

    if (widget.note == null) {
      final newNote = Note(title: title, content: content, date: date);
      await _dbHelper.insert(newNote);
    } else {
      final updatedNote = Note(
        id: widget.note!.id,
        title: title,
        content: content,
        date: date,
      );
      await _dbHelper.update(updatedNote);
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration:  InputDecoration(
            hintText: 'Название',
            hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.5), 
            fontSize: 25,
            fontWeight: FontWeight.w400,
      ),
            border: InputBorder.none,  // Убирает нижнюю границу
            contentPadding: EdgeInsets.symmetric(vertical: 12.0),  // Дополнительное пространство сверху/снизу
          ),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            iconSize: 30.0,
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Введите текст заметки...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
          fontSize: 17,
        ),),
      ),
    );
  }
}
