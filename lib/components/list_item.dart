import 'package:second_ssh/screens/ssh_screen.dart';

import 'analytics.dart';
import 'package:second_ssh/components/api.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:second_ssh/components/helpers.dart';
import 'package:second_ssh/dialogs/dialogs.dart';

class ListItem extends StatefulWidget {
  const ListItem({Key? key, required this.item, required this.statusMsg})
      : super(key: key);
  final String item;
  final Function(String, {bool loading}) statusMsg;
  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  Map<String, bool> hover = {};
  Map<String, bool> expanded = {};
  ScrollController scrollController = ScrollController();

  void update(var item, bool enter) {
    setState(() {
      hover[item] = enter;
    });
  }

  void expand(var item) {
    if (expanded[item] == null || !(expanded[item]!)) {
      setState(() {
        expanded[item] = true;
      });
    } else {
      setState(() {
        expanded[item] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController cmdController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
      child: MouseRegion(
        onEnter: (event) {
          update(widget.item, true);
        },
        onExit: (event) {
          update(widget.item, false);
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    (expanded[widget.item] != null && expanded[widget.item]!)
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0))
                        : const BorderRadius.all(Radius.circular(5.0)),
                color: const Color.fromARGB(255, 58, 56, 56),
              ),
              child: ListTile(
                tileColor: (hover[widget.item] != null && hover[widget.item]!)
                    ? const Color.fromRGBO(0, 0, 0, 0.2)
                    : Colors.transparent,
                title: Text(distroLabel(widget.item)), // running here
                leading: Row(children: [
                  Tooltip(
                    message: 'Start',
                    child: IconButton(
                      icon: const Icon(FluentIcons.play),
                      onPressed: () {},
                    ),
                  ),
                ]),
                trailing: Tooltip(
                  message: 'Expand',
                  child: IconButton(
                    icon: const Icon(FluentIcons.chevron_down),
                    onPressed: () {
                      //plausible.event(name: "wsl_explorer");
                      //api.startExplorer(item, path: path);
                      expand(widget.item);
                      /* if (commandOutput.isEmpty) {
                        SSHAPI().connectPerAlias(widget.item).then((ssh) {
                          ssh.sendCmd('uptime').then((value) =>
                              commandOutput.add(TextSpan(text: value)));
                        });
                      } */
                    },
                  ),
                ),
              ),
            ),
            (expanded[widget.item] != null && expanded[widget.item]!)
                ? QuickCmdBox(
                    scrollController: scrollController,
                    cmdController: cmdController,
                    item: widget.item,
                    statusMsg: widget.statusMsg,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class QuickCmdBox extends StatefulWidget {
  QuickCmdBox({
    Key? key,
    required this.scrollController,
    required this.cmdController,
    required this.item,
    required this.statusMsg,
  }) : super(key: key);

  final ScrollController scrollController;
  final TextEditingController cmdController;
  final String item;
  final Function(String, {bool loading}) statusMsg;

  @override
  State<QuickCmdBox> createState() => _QuickCmdBoxState();
}

class _QuickCmdBoxState extends State<QuickCmdBox> {
  String commandOutput = '';

  void scrollBottom({double offset = 50.0}) {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent + offset,
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
    widget.cmdController.text = '';
    commandOutput += '\n> $cmd'; // add to output
    updateState();
    SSHAPI ssh = SSHAPI();
    ssh = await ssh.connectPerAlias(widget.item);
    if (ssh.error.isNotEmpty) {
      widget.statusMsg('Error: ${ssh.error}', loading: false);
      // Reset error
      ssh.error = '';
      return;
    }
    commandOutput += '\n' + await ssh.sendCmd(cmd);
    if (ssh.error.isNotEmpty) {
      widget.statusMsg('Error: ${ssh.error}', loading: false);
      // Reset error
      return;
    }
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to bottom
    scrollBottom();
    return Container(
      color: const Color.fromARGB(255, 58, 56, 56),
      height: 188.0,
      child: Column(children: [
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
                    Navigator.push(
                        context,
                        FluentPageRoute(
                            builder: (context) => SshPage(item: widget.item)));
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
                    editDialog(context, widget.item, widget.statusMsg);
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
                    deleteDialog(context, widget.item, widget.statusMsg);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 600.0,
          height: 100.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: SelectableText.rich(
                      TextSpan(text: commandOutput),
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
                width: 500.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextBox(
                          onSubmitted: cmdSend,
                          controller: widget.cmdController,
                          placeholder: 'Command')
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 66.0,
                child: Button(
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Text('Send'),
                  ),
                  onPressed: () => cmdSend(widget.cmdController.text),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
