import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

import 'src/notes_editor.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        "/notes_editor": (context) => NotesEditorPage(),
      },
    );
  }
}


class Note {
  final String title;
  final String description;

  Note(this.title, this.description);
}


class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);
  //
  // final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          break;

        case 1:
          Navigator.of(context).pushNamed("/notes_editor");
          break;

        case 2:
          break;
      }
    });
  }


  Widget topSection = Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Hey Harshit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Good morning',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.more_vert,
        ),
      ],
    ),
  );


  Future<List<Note>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return Note(
        "Title : $search $index",
        "Description :$search $index",
      );
    });
  }

  // Widget searchSection = Container(
  //   padding: const EdgeInsets.symmetric(horizontal: 20),
  //   child: SearchBar<Note>(
  //     onSearch: search,
  //     onItemFound: (Note note, int index) {
  //       return ListTile(
  //         title: Text(note.title),
  //         subtitle: Text(note.description),
  //       );
  //     },
  //   ),
  // );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
              children: [
                topSection,
                Container(
                    child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SearchBar<Note>(
                            onSearch: search,
                            hintText: "Search Notes",
                            icon: Icon(Icons.search, size: 30.0,),
                            onItemFound: (Note note, int index) {
                              return ListTile(
                                title: Text(note.title),
                                subtitle: Text(note.description),
                              );
                            },
                          )
                        )
                    ),
                ),
              ]
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
          ),
            label: 'Add Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list,
                      size: 40.0,
                  ),
            label: 'ListView',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
