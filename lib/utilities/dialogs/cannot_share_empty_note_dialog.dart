import 'package:flutter/widgets.dart';
import 'package:flutter_project/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Sharing',
      content: 'You Cannot Share an Empty Note!!',
      optionBuilder: () => {'Ok': null});
}
