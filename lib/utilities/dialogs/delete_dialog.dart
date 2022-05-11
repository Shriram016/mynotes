import 'package:flutter/material.dart';
import 'package:flutter_project/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Delete',
      content: 'Are You Sure You want to Delete this item ??',
      optionBuilder: () => {
            'Cancel': false,
            'Yes': true,
          }).then((value) => value ?? false);
}
