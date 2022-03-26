import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:second_ssh/components/api.dart';
import 'package:second_ssh/components/constants.dart';
import 'package:second_ssh/components/navbar.dart';
import 'package:second_ssh/components/helpers.dart';
import 'package:second_ssh/main.dart';

class SshPage extends StatefulWidget {
  const SshPage({Key? key, required this.item}) : super(key: key);

  final String item;
  @override
  _SshPageState createState() => _SshPageState();
}

class _SshPageState extends State<SshPage> {
  @override
  void initState() {
    super.initState();
  }

  //plausible.event(page: 'create');
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          navbar(themeData, back: true, context: context),
          BigCmdBox(item: widget.item)
        ],
      ),
    );
  }
}

class BigCmdBox extends StatefulWidget {
  const BigCmdBox({
    Key? key,
    required this.item,
  }) : super(key: key);

  final String item;

  @override
  State<BigCmdBox> createState() => _BigCmdBoxState();
}

class _BigCmdBoxState extends State<BigCmdBox> {
  ScrollController scrollController = ScrollController();
  TextEditingController cmdController = TextEditingController();
  String commandOutput = '';

  void scrollBottom({double offset = 50.0}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
          scrollController.position.maxScrollExtent + offset,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeOut);
    }
  }

  void updateState() {
    setState(() {
      commandOutput = commandOutput;
    });
    scrollBottom();
  }

  void cmdSend(cmd) async {
    cmdController.text = '';
    commandOutput += '\n> $cmd'; // add to output
    updateState();
    SSHAPI ssh = SSHAPI();
    ssh = await ssh.connectPerAlias(widget.item);
    if (ssh.error.isNotEmpty) {
      commandOutput += '\n=========\n' + ssh.error + '\n=========\n';
      // Reset error
      ssh.error = '';
      return;
    }
    commandOutput += '\n' + await ssh.sendCmd(cmd);
    if (ssh.error.isNotEmpty) {
      commandOutput += '\n=========\n' + ssh.error + '\n=========\n';
      // Reset error
      return;
    }
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to bottom
    scrollBottom();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Tooltip(
              message: 'Open Full SSH Terminal',
              child: IconButton(
                icon: const Icon(FluentIcons.chrome_full_screen),
                onPressed: () {
                  //plausible.event(name: "wsl_delete");
                  //api.delete(item);
                },
              ),
            ),
            Tooltip(
              message: 'Edit',
              child: IconButton(
                icon: const Icon(FluentIcons.edit),
                onPressed: () {
                  //plausible.event(name: "wsl_delete");
                  //api.delete(item);
                },
              ),
            ),
            Tooltip(
              message: 'Delete',
              child: IconButton(
                icon: const Icon(FluentIcons.delete),
                onPressed: () {
                  //plausible.event(name: "wsl_delete");
                  //api.delete(item);
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText.rich(
                    TextSpan(
                        text: commandOutput,
                        style: const TextStyle(fontFamily: 'ConsoleNormal')),
                  ),
                )),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextBox(
                        onSubmitted: cmdSend,
                        controller: cmdController,
                        placeholder: 'Command')
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.10,
              child: Button(
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text('Send'),
                ),
                onPressed: () => cmdSend(cmdController.text),
              ),
            )
          ],
        ),
      )
    ]);
  }
}
