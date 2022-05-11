import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/constants/routes.dart';
import 'package:flutter_project/enums/menu_action.dart';
import 'package:flutter_project/services/auth/auth_service.dart';
import 'package:flutter_project/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_project/services/auth/bloc/auth_event.dart';
import 'package:flutter_project/services/cloud/cloud_note.dart';
import 'package:flutter_project/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_project/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_project/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // late NotesService _notesService;
  late FirebaseCloudStorage _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();
    // _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogoutDialog(context);
                  if (shouldLogOut) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                    // await AuthService.firebase().logOut();
                    // await Navigator.of(context)
                    //     .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                  break;
              }
            }, itemBuilder: (context) {
              return [
                const PopupMenuItem(
                    value: MenuAction.logout, child: Text('Log Out'))
              ];
            })
          ],
        ),
        body: StreamBuilder(
          // stream: _notesService.allNotes,
          stream: _notesService.allNotes(ownerUserID: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  // final allNotes = snapshot.data as List<DatabaseNotes>;
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      // await _notesService.deleteNote(id: note.id);
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context)
                          .pushNamed(createOrUpdateNoteRoute, arguments: note);
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}


// Below Code is with FutureBuilder Used with Local DataBase

// body: FutureBuilder(
//         future: _notesService.getOrCreateUser(email: userEmail),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               return StreamBuilder(
//                 stream: _notesService.allNotes,
//                 builder: (context, snapshot) {
//                   switch (snapshot.connectionState) {
//                     case ConnectionState.waiting:
//                     case ConnectionState.active:
//                       if (snapshot.hasData) {
//                         final allNotes = snapshot.data as List<DatabaseNotes>;
//                         return NotesListView(
//                           notes: allNotes,
//                           onDeleteNote: (note) async {
//                             await _notesService.deleteNote(id: note.id);
//                           },
//                           onTap: (note) {
//                             Navigator.of(context).pushNamed(
//                                 createOrUpdateNoteRoute,
//                                 arguments: note);
//                           },
//                         );
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     default:
//                       return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               );
//             default:
//               return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),










// Future<bool> showLogoutDialogBox(BuildContext context) {
//   return showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Log Out'),
//         content: const Text('Are you sure you want to log Out?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(false);
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(true);
//             },
//             child: const Text('Log Out'),
//           )
//         ],
//       );
//     },
//   ).then((value) => value ?? false);
// }
