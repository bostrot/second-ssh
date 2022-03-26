import 'package:second_ssh/components/analytics.dart';
import 'package:second_ssh/components/api.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Rename Dialog
/// @param context: context
/// @param statusMsg: Function(String, {bool loading})
editDialog(
    context, String item, Function(String, {bool loading}) statusMsg) async {
  final pwdController = TextEditingController();
  final nameController = TextEditingController();
  final hostController = TextEditingController();
  final userController = TextEditingController();
  final portController = TextEditingController();
  plausible.event(page: 'edit');

  Host host = await SSHAPI().get(item);
  nameController.text = host.alias;
  hostController.text = host.host;
  userController.text = host.username;
  portController.text = host.port.toString();
  pwdController.text = host.password;

  showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: const Text('Edit Host'),
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
                placeholder: host.alias,
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
                      placeholder: host.host,
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
                      placeholder: host.port.toString(),
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
                placeholder: host.username,
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
              plausible.event(name: "host_edit");
              // Replace non A-Z a-z 0-9
              String alias =
                  nameController.text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '');

              String lhost = hostController.text;
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
              if (lhost == '') {
                statusMsg('Host cannot be empty', loading: false);
                return;
              }
              if (user == '') {
                statusMsg('User cannot be empty', loading: false);
                return;
              }
              if (pwd == '') {
                pwd = host.password;
              }
              SSHAPI().edit(
                  item,
                  Host(
                    alias,
                    lhost,
                    port,
                    user,
                    pwd,
                  ));
              Navigator.pop(context);
              statusMsg('Edited host');
            },
            child: const Text('Edit'),
          ),
        ],
      );
    },
  );
}
