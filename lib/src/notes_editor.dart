import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:noteit/src/custom_flutter_summer_note_state.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer';


class NotesEditorPage extends StatefulWidget {
  @override
  _NotesEditorPageState createState() => _NotesEditorPageState();
}

class _NotesEditorPageState extends State<NotesEditorPage> {

  GlobalKey<CustomFlutterSummernoteState> _keyEditor = GlobalKey();
  final _scaffoldState = GlobalKey<ScaffoldState>();
  String result = "";
  String content = "";


  @override
  void initState() {
    super.initState();
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
    return File('$path/summer.txt');
  }


  Future<File> writeContent(String str) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(str);
  }


  Future<String> readContent() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        // Read the file
        String contents = await file.readAsString();
        return contents;
      } else {
        return 'File not found!!';
      }
    } catch (e) {
      // If there is an error reading, return a default String
      return 'Error';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(children: [
            Container(
              // padding: const EdgeInsets.all(32),
              child: Row(children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Builder(
                          builder: (context) =>
                              IconButton(
                                icon: Icon(Icons.save),
                                onPressed: () async {
                                  final value = await _keyEditor.currentState.getText();
                                  writeContent(value).then((_) {
                                    Flushbar(
                                      message: "Saved!!",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                  });
                                },
                              ),
                        )))
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
    );
  }
}