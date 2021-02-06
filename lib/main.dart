import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:noteit/src/encrypt_key_keystore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:async';
import 'dart:developer';

import 'package:noteit/src/Database.dart';
import 'package:noteit/src/NotesModel.dart';
import 'package:noteit/src/notes_editor.dart';
import 'package:noteit/src/NotesCard.dart';


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
          ).then((value) => {
            setState(() {}),
          });
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


  Future<List<Notes>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return new Notes(
        id: 0,
        createdOn: DateTime.now(),
        lastEditedOn: DateTime.now(),
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
                            child: SearchBar<Notes>(
                            onSearch: search,
                            hintText: "Search Notes",
                            icon: Icon(Icons.search, size: 30.0,),
                            onItemFound: (Notes note, int index) {
                              return ListTile(
                                title: Text(note.id.toString()),
                                subtitle: Text(note.createdOn.toString()),
                              );
                            },
                          )
                        )
                    ),
                ),
                Container(
                  child: Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DefaultTabController(
                            length: 3,
                            child: Scaffold(
                              appBar: TabBar(
                                labelColor: Colors.black,
                                isScrollable: true,
                                unselectedLabelColor: Colors.black.withOpacity(0.3),
                                indicatorColor: Colors.blue,
                                tabs: [
                                  Tab(text: 'Notes'),
                                  Tab(text: 'SECOND',),
                                  Tab(text: 'THIRD'),
                                ],
                              ),
                              body: TabBarView(
                                children: [
                                  FirstScreen(context, this),
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



class FirstScreen extends StatefulWidget {
  BuildContext mainContext;
  _MyHomePageState root;

  FirstScreen(this.mainContext, this.root);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}


class _FirstScreenState extends State<FirstScreen> {

  refresh() {
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: FutureBuilder(
            future: DBProvider.db.getAllNotes(),
            builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
              if (snapshot.hasData) {
                int index = 0;
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  //this is what you actually need
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 4, // I only need two card horizontally
                    itemCount: snapshot.data.length,
                    padding: const EdgeInsets.all(2.0),
                    itemBuilder: (BuildContext context, int index) => NotesCard(notifyParent: refresh, item: snapshot.data[index], mainContext: widget.mainContext, index: index),
                    // children: snapshot.data.map<Widget>((item) {
                    //   //Do you need to go somewhere when you tap on this card, wrap using InkWell and add your route
                    //   return NotesCard(item, widget.mainContext, index++);
                    // }).toList(),

                    //Here is the place that we are getting flexible/ dynamic card for various images
                    // staggeredTiles: snapshot.data
                    //     .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                    //     .toList(),
                    staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0, // add some space
                  ),
                );
              }

              // if (snapshot.hasData) {
              //   return GridView.builder(
              //     itemCount: snapshot.data.length,
              //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2),
              //     itemBuilder: (BuildContext context, int index) {
              //       Notes item = snapshot.data[index];
              //       return GestureDetector(
              //         onTap: () => {
              //           Navigator.push(
              //             widget.mainContext,
              //             MaterialPageRoute(builder: (context) => NotesEditorPage(item.id)),
              //           ).then((value) => {
              //             setState(() {}),
              //           }),
              //         },
              //         child: Container(
              //           margin:EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              //           decoration: BoxDecoration(
              //             color: colorList[index%(colorList.length)],
              //             // border: Border.all(
              //             //     color: Colors.blueAccent,
              //             //     width: 2
              //             // ),
              //             borderRadius: BorderRadius.all(
              //                 Radius.circular(10.0) //                 <--- border radius here
              //             ),
              //             // boxShadow: [BoxShadow(blurRadius: 10,color: Colors.black,offset: Offset(1,3))]
              //           ),
              //           child: Center(
              //             child: Column(
              //               children: [
              //                 Text(item.createdOn.toString()),
              //                 Text(item.id.toString()),
              //                 Text(item.lastEditedOn.toString()),
              //               ]
              //               // Checkbox(
              //               //   onChanged: (bool value) {
              //               //     DBProvider.db.blockClient(item);
              //               //     setState(() {});
              //               //   },
              //               //   value: item.blocked,
              //               // ),
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   );
              //   // return ListView.builder(
              //   //   itemCount: snapshot.data.length,
              //   //   itemBuilder: (BuildContext context, int index) {
              //   //     Notes item = snapshot.data[index];
              //   //     return GestureDetector(
              //   //       onTap: () => {
              //   //         Navigator.push(
              //   //           widget.mainContext,
              //   //           MaterialPageRoute(builder: (context) => NotesEditorPage(item.id)),
              //   //         ).then((value) => {
              //   //             setState(() {}),
              //   //         }),
              //   //       },
              //   //       child: ListTile(
              //   //         title: Text(item.createdOn.toString()),
              //   //         leading: Text(item.id.toString()),
              //   //         trailing: Text(item.lastEditedOn.toString()),
              //   //         // Checkbox(
              //   //         //   onChanged: (bool value) {
              //   //         //     DBProvider.db.blockClient(item);
              //   //         //     setState(() {});
              //   //         //   },
              //   //         //   value: item.blocked,
              //   //         // ),
              //   //       ),
              //   //     );
              //   //   },
              //   // );
              // }
              else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
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


