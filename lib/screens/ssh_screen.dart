import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:second_ssh/components/api.dart';
import 'package:second_ssh/components/constants.dart';
import 'package:second_ssh/components/navbar.dart';
import 'package:second_ssh/components/helpers.dart';
import 'package:second_ssh/main.dart';

import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/next.dart';

class SshPage extends StatefulWidget {
  const SshPage({Key? key, required this.item}) : super(key: key);

  final String item;
  @override
  _SshPageState createState() => _SshPageState();
}

class _SshPageState extends State<SshPage> {
  final terminal = Terminal(maxLines: 10000);

  SSHClient? client;
  SSHSession? session;
  final controller = ScrollController();
  bool loaded = false;

  Future<void> initTerminal() async {
    Host host = await SSHAPI().get(widget.item);
    client = SSHClient(
      await SSHSocket.connect(host.host, host.port),
      username: host.username,
      onPasswordRequest: () => host.password,
    );

    session = await client!.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    session!.stdout
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(terminal.write);

    session!.stderr
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(terminal.write);

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      session!.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    terminal.onOutput = (data) {
      session!.write(utf8.encode(data) as Uint8List);
    };
  }

  @override
  void initState() {
    super.initState();
    initTerminal();
  }

  //plausible.event(page: 'create');
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          navbar(themeData, back: true, context: context),
          //BigCmdBox(item: widget.item)
          loaded
              ? SafeArea(
                  child: SizedBox(
                    height: 100.0,
                    width: 400.0,
                    child: TerminalView(
                      terminal,
                    ),
                  ),
                )
              : Container(),
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

  void onInput(String input) {}

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
    ]);
  }
}
