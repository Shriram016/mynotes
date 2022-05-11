import 'package:flutter/material.dart';
import 'package:flutter_project/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: 'Log Out',
          content: 'Are You Sure You want to Log Out ??',
          optionBuilder: () => {'Cancel': false, 'Log Out': true})
      .then((value) => value ?? false);
}
