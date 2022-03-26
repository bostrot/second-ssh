import 'package:second_ssh/components/analytics.dart';
import 'package:second_ssh/components/api.dart';
import 'package:second_ssh/dialogs/base_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:second_ssh/components/helpers.dart';

/// Delete Dialog
/// @param context: context
/// @param item: distro name
/// @param api: WSLApi
/// @param statusMsg: status message
deleteDialog(context, item, Function(String, {bool loading}) statusMsg) {
  plausible.event(page: 'delete');
  dialog(
      context: context,
      item: item,
      statusMsg: statusMsg,
      title: 'Delete \'${item}\' permanently?',
      body: 'If you delete this Host you won\'t be able to recover it.'
          ' Do you want to delete it?',
      submitText: 'Delete',
      submitInput: false,
      submitStyle: ButtonStyle(
        backgroundColor: ButtonState.all(Colors.red),
        foregroundColor: ButtonState.all(Colors.white),
      ),
      onSubmit: (inputText) {
        SSHAPI().remove(item);
        statusMsg('DONE: Deleted $item.');
      });
}
