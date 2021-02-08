import 'package:flutter/cupertino.dart';
import 'package:noteit/src/NotesModel.dart';
import 'package:flutter/material.dart';
import 'package:noteit/src/notes_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:noteit/src/encrypt_key_keystore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:convert';

class NotesCard extends StatefulWidget {
  Notes item;
  int index;
  BuildContext mainContext;

  final Function() notifyParent;

  NotesCard(
      {Key key,
      @required this.notifyParent,
      this.item,
      this.mainContext,
      this.index})
      : super(key: key);

  @override
  _NotesCardState createState() => _NotesCardState();
}

class _NotesCardState extends State<NotesCard> {
  String notesData = '';
  var cryptor = new PlatformStringCryptor();
  String encryptionKey = EncryptKeyFromKeystore.encryptionKey;

  List<Color> colorList = [
    Color(0xffd3e0ea),
    Color(0xffe3d0b9),
    Color(0xffffdcdc),
    Color(0xffdfe0df),
    Color(0xffbee5d3),
    Color(0xffd1a2f2),
    Color(0xffe6d5b8),
    Color(0xff99a8b2),
    Color(0xff9ab3f5),
    Color(0xffffd5cd)
  ];


  Future<String> readNotesData() async {
    await readContent(widget.item.id).then((val) {
      setState(() {
        notesData = val;
      });
    });
    return notesData;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(int noteId) async {
    final path = await _localPath;
    return File('$path/$noteId.txt');
  }

  Future<String> readContent(int noteId) async {
    try {
      final file = await _localFile(noteId);
      if (await file.exists()) {
        // Read the file
        String encrypted = await file.readAsString();
        String decrypted = await cryptor.decrypt(encrypted, encryptionKey);
        return decrypted;
      } else {
        return '';
      }
    } catch (e) {
      // If there is an error reading, return a default String
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          widget.mainContext,
          MaterialPageRoute(
              builder: (context) => NotesEditorPage(widget.item.id)),
        ).then((value) => {
              widget.notifyParent(),
            }),
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorList[widget.index % (colorList.length)],
          // border: Border.all(
          //     color: Colors.blueAccent,
          //     width: 2
          // ),
          borderRadius: BorderRadius.all(
              Radius.circular(10.0) //                 <--- border radius here
              ),
          // boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]
        ),
        child: Center(
          child: Column(children: [
            FutureBuilder<String>(
              future: readContent(widget.item.id),
              // a Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {

                  // parsing html string
                  var document = parse(snapshot.data);
                  var images = document.getElementsByTagName('img');

                  if (images.isNotEmpty) {
                    var image = images[0];
                    var src = image.attributes['src'];
                    src = src.split(',').last.replaceAll('<br>', "");

                    // formatting data without image
                    var withoutImageData = snapshot.data.replaceAll(RegExp('<img[^>]*>'), "");
                    withoutImageData = withoutImageData.replaceAll('<br>', "");
                    withoutImageData = withoutImageData.replaceAll('<p></p>', "");
                    withoutImageData = withoutImageData.replaceAll('<p><br/></p>', "");
                    withoutImageData = withoutImageData.replaceAll('<p>', '<br>');
                    withoutImageData = withoutImageData.replaceAll('</p>', "");


                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Image.memory(
                        base64.decode(src.split(',').last),
                        height: 200,
                        fit:BoxFit.fill
                      ),
                      Html(data: '<b>Image note</b>'),
                      // TextFormField(initialValue: Html(data: '$withoutImageData').toString(), maxLines: 2),
                      Container(
                        constraints: BoxConstraints(minHeight: 50, maxHeight: 50),
                        child: ClipRect(
                          child: Html(data: '$withoutImageData'),
                        ),
                      ),
                    ]);
                  } else {

                    // formatting data without image
                    var withoutImageData = snapshot.data.replaceAll(RegExp('<img[^>]*>'), "");
                    withoutImageData = withoutImageData.replaceAll('<br>', "");
                    withoutImageData = withoutImageData.replaceAll('<p></p>', "");
                    withoutImageData = withoutImageData.replaceAll('<p><br/></p>', "");
                    withoutImageData = withoutImageData.replaceAll('<p>', '<br>');
                    withoutImageData = withoutImageData.replaceAll('</p>', "");

                    return Container(
                      constraints: BoxConstraints(minHeight: 50, maxHeight: 98),
                      child: ClipRect(
                        child: Html(data: '$withoutImageData'),
                      ),
                    ); // snapshot.data  :- get your object which is pass from your downloadData() function
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Row(
              children: <Widget>[
                Text(
                  DateTime.parse(widget.item.lastEditedOn.toString()).format('D j M, Y g:i A'),
                  style: new TextStyle(
                    fontSize: 12.0,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.left,
                ),
                Spacer()
              ],
            )
          ]
              // Checkbox(
              //   onChanged: (bool value) {
              //     DBProvider.db.blockClient(item);
              //     setState(() {});
              //   },
              //   value: item.blocked,
              // ),
              ),
        ),
      ),
    );
  }
}
