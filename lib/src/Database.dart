import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:noteit/src/NotesModel.dart';



class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "NotesDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Notes ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "createdOn DATETIME,"
          "lastEditedOn DATETIME"
          ")");
    });
  }

  newNote() async {
    final db = await database;
    var res = await db.rawInsert(
        "INSERT Into Notes (createdOn, lastEditedOn)"
            " VALUES (CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)");
    return res;
  }


  getAllNotes() async {
    final db = await database;
    var res = await db.query("Notes", columns: Notes.columns, orderBy: "lastEditedOn DESC");
    List<Notes> list =
    res.isNotEmpty ? res.map((c) => Notes.fromMap(c)).toList() : [];
    return list;
  }

  deleteNote(int id) async {
    final db = await database;
    db.delete("Notes", where: "id = ?", whereArgs: [id]);
  }

  updateNote(int id) async {
    final db = await database;
    var table = await db.rawQuery("SELECT createdOn FROM Notes WHERE id = ?", [id]);
    DateTime createdOn = table.first["createdOn"];
    Notes updatedNote = new Notes(id: id, createdOn: createdOn, lastEditedOn: DateTime.now());
    var res = await db.update("Notes", updatedNote.toMap(),
        where: "id = ?", whereArgs: [updatedNote.id]);
    return res;
  }

}