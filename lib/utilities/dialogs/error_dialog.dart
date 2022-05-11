import 'package:flutter/widgets.dart';
import 'package:flutter_project/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
