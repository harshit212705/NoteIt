import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:noteit/src/encrypt_key_keystore.dart';
import 'dart:async';
import 'dart:developer';


import 'src/notes_editor.dart';

void main() async {
  runApp(MyApp());

    EncryptKeyFromKeystore keyGenerationObj = new EncryptKeyFromKeystore();
    await keyGenerationObj.generateEncryptionKey();
    // String encryptionKey = EncryptKeyFromKeystore.encryptionKey;

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
          int id = 0;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesEditorPage(id)),
          );
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
            // mainAxisSize: MainAxisSize.min,
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
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                topSection,
                Container(
                  height: 80,
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
                Container(
                  child: Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DefaultTabController(
                            length: 3,
                            child: Scaffold(
                              appBar: TabBar(
                                labelColor: Colors.black,
                                isScrollable: true,
                                unselectedLabelColor: Colors.black.withOpacity(0.3),
                                indicatorColor: Colors.blue,
                                tabs: [
                                  Tab(text: 'FIRST'),
                                  Tab(text: 'SECOND',),
                                  Tab(text: 'THIRD'),
                                ],
                              ),
                              body: TabBarView(
                                children: [
                                  FirstScreen(),
                                  SecondScreen(),
                                  ThirdScreen()
                                ],
                              ),
                            ),
                          ),
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


class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child:
                Text('First Activity Screen',
                  style: TextStyle(fontSize: 21),)
            )
        )
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child:
                Text('Second Activity Screen',
                  style: TextStyle(fontSize: 21),)
            )
        )
    );
  }
}

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child:
                Text('Third Activity Screen',
                  style: TextStyle(fontSize: 21),)
            )
        )
    );
  }
}