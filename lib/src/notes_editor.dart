import 'package:flutter/material.dart';
// import 'package:flushbar/flushbar.dart';
// import 'package:overlay_support/overlay_support.dart';
import 'package:toast/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:noteit/src/custom_flutter_summer_note_state.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:noteit/src/encrypt_key_keystore.dart';
import 'package:noteit/src/Database.dart';
import 'package:noteit/src/NotesModel.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer';


class NotesEditorPage extends StatefulWidget {
  int noteId;

  NotesEditorPage(int noteId) {
    this.noteId = noteId;
  }

  @override
  _NotesEditorPageState createState() => _NotesEditorPageState(noteId);
}

class _NotesEditorPageState extends State<NotesEditorPage> {

  GlobalKey<CustomFlutterSummernoteState> _keyEditor = GlobalKey();
  final _scaffoldState = GlobalKey<ScaffoldState>();
  String result = "";
  String content = "";
  var cryptor;
  String encryptionKey;
  int notesFileNumber;

  _NotesEditorPageState(int noteId) {
    this.notesFileNumber = noteId;
    if (notesFileNumber == 0) {
      generateNewNote();
    }
  }

  void generateNewNote() async {
    notesFileNumber = await DBProvider.db.newNote();
  }

  @override
  void initState() {
    super.initState();
    cryptor = new PlatformStringCryptor();
    encryptionKey = EncryptKeyFromKeystore.encryptionKey;
    readContent().then((val) {
      setState(() {
        content = val;
      });
    });
  }


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }


  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$notesFileNumber.txt');
  }


  Future<File> writeContent(String str) async {
    final file = await _localFile;

    final encrypted = await cryptor.encrypt(str, encryptionKey);
    // Write the file
    return file.writeAsString(encrypted);
  }


  Future<String> readContent() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        // Read the file
        String encrypted = await file.readAsString();
        final decrypted = await cryptor.decrypt(encrypted, encryptionKey);
        return decrypted;
      } else {
        return '';
      }
    } catch (e) {
      // If there is an error reading, return a default String
      return '';
    }
  }


  Future<int> deleteFile() async {
    try {
      final file = await _localFile;

      await file.delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit'),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new TextButton(
            onPressed: () async {
              final value = await _keyEditor.currentState.getText();
              if (value == '') {
                DBProvider.db.deleteNote(notesFileNumber);
                deleteFile();
              }
              else {
                DBProvider.db.updateNote(notesFileNumber);
                writeContent(value).then((_) {
                  // notes data written to file
                });
              }
              Navigator.of(context).pop(true);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
        key: _scaffoldState,
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(children: [
              Container(
                // padding: const EdgeInsets.all(32),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (context) =>
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () async {
                                    final value = await _keyEditor.currentState.getText();
                                    if (value == '') {
                                      DBProvider.db.deleteNote(notesFileNumber);
                                      deleteFile();
                                    }
                                    else {
                                      DBProvider.db.updateNote(notesFileNumber);
                                      writeContent(value).then((_) {
                                        // notes data written to file
                                      });
                                    }
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                          )
                      )
                  ),
                  Spacer(),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Builder(
                            builder: (context) =>
                                IconButton(
                                  icon: Icon(Icons.save),
                                  onPressed: () async {
                                    final value = await _keyEditor.currentState.getText();
                                    DBProvider.db.updateNote(notesFileNumber);
                                    writeContent(value).then((_) {
                                      // Flushbar(
                                      //   message: "Saved!!",
                                      //   duration: Duration(seconds: 1),
                                      // )..show(context);
                                      Toast.show("Saved!!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                                    });
                                  },
                                ),
                          )
                      )
                  ),
                ]),
              ),
              Expanded(
                child: CustomFlutterSummernote(
                  // hint: "Your text here...",
                  key: _keyEditor,
                  value: content,
                  // hasAttachment: false,
                  customToolbar: """
              [
                ['style', ['bold', 'italic', 'underline', 'clear']],
                ['font', ['strikethrough', 'superscript', 'subscript']],
                ['insert', ['link', 'table', 'hr']]
              ]
            """,
                ),
              )
            ]
          )
        ),
      ),
    );
  }
}