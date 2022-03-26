import 'package:second_ssh/components/analytics.dart';
import 'package:second_ssh/components/api.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:second_ssh/components/constants.dart';
import 'package:second_ssh/components/helpers.dart';

/// Rename Dialog
/// @param context: context
/// @param api: WSLApi
/// @param statusMsg: Function(String, {bool loading})
createDialog(context, Function(String, {bool loading}) statusMsg) {
  final pwdController = TextEditingController();
  final nameController = TextEditingController();
  final hostController = TextEditingController();
  final userController = TextEditingController();
  final portController = TextEditingController();
  plausible.event(page: 'create');

  showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: const Text('Add a Host'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 10.0,
            ),
            const Text(
              'Alias:',
            ),
            Container(
              height: 5.0,
            ),
            Tooltip(
              message: 'The Alias for the host',
              child: TextBox(
                controller: nameController,
                placeholder: 'Server One',
              ),
            ),
            Container(
              height: 10.0,
            ),
            const Text(
              'Host:',
            ),
            Container(
              height: 5.0,
            ),
            Row(
              children: [
                SizedBox(
                  width: 250.0,
                  child: Tooltip(
                    message: 'The Hostname/IP of the host',
                    child: TextBox(
                      controller: hostController,
                      placeholder: '192.168.1.100',
                    ),
                  ),
                ),
                SizedBox(
                  width: 75.0,
                  child: Tooltip(
                    message: 'The Port of the host',
                    child: TextBox(
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      controller: portController,
                      placeholder: '22',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 10.0,
            ),
            const Text(
              'User:',
            ),
            Container(
              height: 5.0,
            ),
            Tooltip(
              message: 'The Username for the host',
              child: TextBox(
                controller: userController,
                placeholder: 'root',
              ),
            ),
            Container(
              height: 10.0,
            ),
            const Text(
              'Password:',
            ),
            Container(
              height: 5.0,
            ),
            Tooltip(
              message: 'The Password for the host',
              child: TextBox(
                obscureText: true,
                controller: pwdController,
                placeholder: '********',
              ),
            ),
          ],
        ),
        actions: [
          Button(
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.pop(context);
              }),
          Button(
            onPressed: () async {
              plausible.event(name: "wsl_create");
              // Replace non A-Z a-z 0-9
              String alias =
                  nameController.text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '');

              String host = hostController.text;
              int port = 22;
              if (portController.text != '') {
                try {
                  port = int.parse(portController.text);
                } catch (e) {
                  statusMsg('The port is invalid', loading: false);
                  return;
                }
              }
              String user = userController.text;
              String pwd = pwdController.text;
              if (alias == '') {
                statusMsg('Alias cannot be empty', loading: false);
                return;
              }
              if (host == '') {
                host = '192.168.1.100';
              }
              if (user == '') {
                user = 'root';
              }
              SSHAPI().add(Host(alias, host, port, user, pwd));
              Navigator.pop(context);
              statusMsg('Added host');
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
