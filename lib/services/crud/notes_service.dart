// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_project/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'crud_exceptions.dart';

// const dbName = 'myNotes.db';
// const notesTable = 'notes';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''
//         CREATE TABLE IF NOT EXISTS "user" (
//           "id"	INTEGER NOT NULL,
//           "email"	TEXT NOT NULL UNIQUE,
//           PRIMARY KEY("id" AUTOINCREMENT)
//           );''';

// const createNotesTable = '''
//           CREATE TABLE IF NOT EXISTS "notes" (
//             "id"	INTEGER NOT NULL,
//             "user_id"	INTEGER NOT NULL,
//             "text"	TEXT NOT NULL,
//             "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//             PRIMARY KEY("id" AUTOINCREMENT),
//             FOREIGN KEY("user_id") REFERENCES "user"("id")
//           );''';

// class NotesService {
//   Database? _db;

//   List<DatabaseNotes> _notes = [];

//   DatabaseUser? _user;

//   // Make NotesService a Singleton
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController =
//         StreamController<List<DatabaseNotes>>.broadcast(onListen: () {
//       _notesStreamController.sink.add(_notes);
//     });
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNotes>> _notesStreamController;

//   Stream<List<DatabaseNotes>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNotes> updateNote(
//       {required DatabaseNotes note, required String text}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();

//     // Making sure that Note Exists
//     await getNote(id: note.id);

//     // Update DB
//     final updatesCount = await db.update(
//         notesTable,
//         {
//           textColumn: text,
//           isSyncedWithCloudColumn: 0,
//         },
//         where: 'id =?',
//         whereArgs: [note.id]);
//     if (updatesCount == 0) {
//       throw CoundNotUpdateNoteException();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<Iterable<DatabaseNotes>> getAllNotes() async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(notesTable);
//     final results = notes.map((row) => DatabaseNotes.fromRow(row));
//     return results;
//   }

//   Future<DatabaseNotes> getNote({required int id}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id=?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNotFindNotes();
//     } else {
//       final note = DatabaseNotes.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(notesTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedcount = await db.delete(
//       notesTable,
//       where: 'id =?',
//       whereArgs: [id],
//     );
//     if (deletedcount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();

//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }
//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNotes(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email =?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email =?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }

//     final myid = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(
//       id: myid,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDBisOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email =?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       // create User Table
//       await db.execute(createUserTable);
//       // Create Notes Table
//       await db.execute(createNotesTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectoryException();
//     }
//   }

//   Future<void> _ensureDBisOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // Empty, Do Nothing
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   // Covariant helps to compare two database Users by overriding '==' operator
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
// }

// class DatabaseNotes {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNotes({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNotes.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Notes, ID = $id, userID = $userId, isSyncedwithCloud = $isSyncedWithCloud, text = $text';

//   @override
//   bool operator ==(covariant DatabaseNotes other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }
