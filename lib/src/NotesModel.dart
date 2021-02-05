class Notes {
  int id;
  DateTime createdOn;
  DateTime lastEditedOn;
  static final columns = ["id", "createdOn", "lastEditedOn"];
  Notes({
    this.id,
    this.createdOn,
    this.lastEditedOn,
  });

  factory Notes.fromMap(Map<String, dynamic> json) => new Notes(
    id: json["id"],
    createdOn: DateTime.parse(json["createdOn"]),
    lastEditedOn: DateTime.parse(json["lastEditedOn"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "createdOn": createdOn,
    "lastEditedOn": lastEditedOn,
  };
}
