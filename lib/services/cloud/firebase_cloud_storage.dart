import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/services/cloud/cloud_note.dart';
import 'package:flutter_project/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_project/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote(
      {required String documentID, required String text}) async {
    try {
      await notes.doc(documentID).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Snapshots() => returns a Stream of data, which helps to you to
  // keep updated on Each Changes Made to the data
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserID}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserID));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserID}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserID,
          )
          .get()
          .then((value) => value.docs.map(
                (doc) => CloudNote.fromSnapshot(doc),
              ));
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: "",
    );
  }

  // Create Singleton of FirebaseCloudStorage
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
