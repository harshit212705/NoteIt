library custom_flutter_summernote;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';



class CustomFlutterSummernote extends StatefulWidget {
  final String value;
  final double height;
  final BoxDecoration decoration;
  final String widthImage;
  final String hint;
  final String customToolbar;

  CustomFlutterSummernote({
    Key key,
    this.value,
    this.height,
    this.decoration,
    this.widthImage:"100%",
    this.hint,
    this.customToolbar
  }): super(key: key);

  @override
  CustomFlutterSummernoteState createState() => CustomFlutterSummernoteState();
}

class CustomFlutterSummernoteState extends State<CustomFlutterSummernote> {
  WebViewController _controller;
  String text = "";
  String _page;
  final Key _mapKey = UniqueKey();
  final _imagePicker = ImagePicker();

  void handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == "getRawTeXHTML") {
      } else {}
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _page = _initPage(widget.customToolbar);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height,
      decoration: widget.decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Color(0xffececec), width: 1),
          ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              key: _mapKey,
              onWebResourceError: (e) {
                print("error ${e.description}");
              },
              onWebViewCreated: (webViewController) {
                _controller = webViewController;
                final String contentBase64 = base64Encode(const Utf8Encoder().convert(_page));
                _controller.loadUrl('data:text/html;base64,$contentBase64');
              },
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              gestureRecognizers: [
                Factory(
                        () => VerticalDragGestureRecognizer()..onUpdate = (_) {}),
              ].toSet(),
              javascriptChannels: <JavascriptChannel>[
                getTextJavascriptChannel(context)
              ].toSet(),
              onPageFinished: (String url) {
                if (widget.hint != null) {
                  setHint(widget.hint);
                } else {
                  setHint("");
                }

                setFullContainer();
                if (widget.value != null) {
                  setText(widget.value);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => _attach(context),
                  child: Row(children: <Widget>[
                    Icon(Icons.attach_file),
                    Text("Attachments")
                  ], mainAxisAlignment: MainAxisAlignment.center),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    String data = await getText();
                    Clipboard.setData(new ClipboardData(text: data));
                  },
                  child: Row(children: <Widget>[
                    Icon(Icons.content_copy),
                    Text("Copy")
                  ], mainAxisAlignment: MainAxisAlignment.center),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    ClipboardData data =
                    await Clipboard.getData(Clipboard.kTextPlain);

                    String txtIsi = data.text
                        .replaceAll("'", '\\"')
                        .replaceAll('"', '\\"')
                        .replaceAll("[", "\\[")
                        .replaceAll("]", "\\]")
                        .replaceAll("\n", "<br/>")
                        .replaceAll("\n\n", "<br/>")
                        .replaceAll("\r", " ")
                        .replaceAll('\r\n', " ");
                    String txt =
                        "\$('.note-editable').append( '" + txtIsi + "');";
                    _controller.evaluateJavascript(txt);
                  },
                  child: Row(children: <Widget>[
                    Icon(Icons.content_paste),
                    Text("Paste")
                  ], mainAxisAlignment: MainAxisAlignment.center),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }

  JavascriptChannel getTextJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'GetTextSummernote',
        onMessageReceived: (JavascriptMessage message) {
          String isi = message.message;
          if (isi.isEmpty ||
              isi == "<p></p>" ||
              isi == "<p><br></p>" ||
              isi == "<p><br/></p>") {
            isi = "";
          }
          setState(() {
            text = isi;
          });
        });
  }

  Future<String> getText() async {
    await _controller.evaluateJavascript(
        "GetTextSummernote.postMessage(document.getElementsByClassName('note-editable')[0].innerHTML);");
    return text;
  }

  setText(String v) async {
    String txtIsi = v
        .replaceAll("'", '\\"')
        .replaceAll('"', '\\"')
        .replaceAll("[", "\\[")
        .replaceAll("]", "\\]")
        .replaceAll("\n", "<br/>")
        .replaceAll("\n\n", "<br/>")
        .replaceAll("\r", " ")
        .replaceAll('\r\n', " ");
    String txt =
        "document.getElementsByClassName('note-editable')[0].innerHTML = '" +
            txtIsi +
            "';";
    _controller.evaluateJavascript(txt);
  }

  setFullContainer() {
    _controller.evaluateJavascript(
        '\$("#summernote").summernote("fullscreen.toggle");');
  }

  setFocus() {
    _controller.evaluateJavascript("\$('#summernote').summernote('focus');");
  }

  setEmpty() {
    _controller.evaluateJavascript("\$('#summernote').summernote('reset');");
  }

  setHint(String text) {
    String hint = '\$(".note-placeholder").html("$text");';
    _controller.evaluateJavascript(hint);
  }

  Widget widgetIcon(IconData icon, String title, {Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.black38,
            size: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  String _initPage(String customToolbar){
    String toolbar;
    if(customToolbar == null){
      toolbar = _defaultToolbar;
    }
    else {
      toolbar = customToolbar;
    }

    return '''<html lang="en">
    <head>
    <meta charset="UTF-8">
    <title>Summernote with Bootstrap 4</title>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
    
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.js"></script>
    </head>
    <body>
    <div id="summernote"></div>
    <script>
      \$("#summernote").summernote({
        placeholder: 'Your text here...',
        tabsize: 2,
        toolbar: $toolbar
      });
    </script>
    </body>
    </html>''';
  }

  String _defaultToolbar = """
    [
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['font', ['strikethrough', 'superscript', 'subscript']],
      ['font', ['fontsize', 'fontname']],
      ['color', ['forecolor', 'backcolor']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['view', ['fullscreen']]
    ]
  """;

  void _attach(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return Column(children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Camera"),
              subtitle: Text("Attach image from camera"),
              onTap: () async {
                Navigator.pop(context);
                final image = await _getImage(true);
                if(image != null) _addImage(image);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Gallery"),
              subtitle: Text("Attach image from gallery"),
              onTap: () async {
                Navigator.pop(context);
                final image = await _getImage(false);
                if(image != null) _addImage(image);
              },
            ),
          ], mainAxisSize: MainAxisSize.min);
        }
    );
  }

  Future<File> _getImage(bool fromCamera) async {
    final picked = await _imagePicker.getImage(source: (fromCamera) ? ImageSource.camera : ImageSource.gallery);
    if(picked != null){
      return File(picked.path);
    }
    else {
      return null;
    }
  }

  void _addImage(File image) async {
    String filename = basename(image.path);

    File compressedImage = await compressFile(image);

    List<int> imageBytes = await compressedImage.readAsBytes();
    String base64Image =
        "<img width=\"${widget.widthImage}\" src=\"data:image/png;base64, "
        "${base64Encode(imageBytes)}\" data-filename=\"$filename\"><br><br>";

    String txt =
        "\$('.note-editable').append( '" + base64Image + "');";
    // log(txt);
    _controller.evaluateJavascript(txt);
  }

  Future<File> compressFile(File file) async {
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, outPath,
      quality: 10,
    );

    // print(file.lengthSync());
    // print(result.lengthSync());

    return result;
  }

}