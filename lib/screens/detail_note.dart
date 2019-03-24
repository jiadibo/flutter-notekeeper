import 'package:flutter/material.dart';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:note_keeper/main.dart';

class DetailNote extends StatefulWidget {
  final String title;
  final Note note;

  DetailNote(this.note, this.title);

  @override
  _DetailNoteState createState() => _DetailNoteState(this.note, this.title);
}

class _DetailNoteState extends State<DetailNote> {
  static var _letak = ['Teratas', 'Biasa'];

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController subController = TextEditingController();
  NoteKeeper noteKeeper = NoteKeeper();

  String title;
  Note note;

  _DetailNoteState(this.note, this.title);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    subController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              DropdownButton(
                items: _letak.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                value: getPriorityAsString(note.priority),
                onChanged: (valueSelected) {
                  setState(() {
                    debugPrint("Select $valueSelected");
                    updatePriorityAsInt(valueSelected);
                  });
                },
              ),
              //Form Title
              SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: titleController,
                onChanged: (value) {
                  debugPrint("Something write title");
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
              //Form SubTitle
              SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: subController,
                onChanged: (value) {
                  debugPrint("Something write title");
                  updateDescripton();
                },
                decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.blue[500],
                      textColor: Colors.white,
                      child: Text("SIMPAN"),
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.blue[500],
                      textColor: Colors.white,
                      child: Text("HAPUS"),
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
    
  }

// convert the string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'Teratas':
        note.priority = 1;
        break;
      case 'Biasa':
        note.priority = 2;
        break;
    }
  }

  // convert integer priority to string priority and display it to user DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _letak[0];
        break;
      case 2:
        priority = _letak[1];
        break;
    }

    return priority;
  }

  // update note title of note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // update note description of note object
  void updateDescripton() {
    note.description = subController.text;
  }

  void _save() async {
    moveToLastScreen();

    int result;
    if (note.id != null) {
      //case 1 : update operation
      result = await helper.updateNote(note);
    } else {
      //case 2 : insert operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      //success
      _showAlertDialog('Status', 'note save successfull');
    } else {
      //failure
      _showAlertDialog('Status', 'Problem saving note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // case 1 : if user trying to delete the new note
    //i.e. he has come to  the detail page by pressing FAB of the notelist page
    if (note.id == null) {
      _showAlertDialog('status', 'no note was deleted');
      return;
    }

    // case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note delete successfuly');
    } else {
      _showAlertDialog('Status', 'Error Occured while deleting Note');
    }
  }

  void _showAlertDialog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
