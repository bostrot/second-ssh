import 'package:second_ssh/components/api.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:second_ssh/dialogs/dialogs.dart';
import 'package:second_ssh/main.dart';
import 'list_item.dart';
import 'helpers.dart';

class DistroList extends StatefulWidget {
  const DistroList({Key? key, required this.statusMsg}) : super(key: key);

  final Function(String, {bool loading}) statusMsg;

  @override
  _DistroListState createState() => _DistroListState();
}

class _DistroListState extends State<DistroList> {
  Map<String, bool> hover = {};
  Map<String, bool> expanded = {};
  bool isSyncing = false;
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

  void syncing(var item) {
    setState(() {
      isSyncing = item;
    });
  }

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return distroList(widget.statusMsg, update, expand, hover, expanded);
  }
}

FutureBuilder<List<String>> distroList(
    Function(String, {bool loading}) statusMsg,
    Function(dynamic, bool) update,
    Function(dynamic) expand,
    Map<String, bool> hover,
    Map<String, bool> expanded) {
  isRunning(String distroName, List<String> runningList) {
    if (runningList.contains(distroName)) {
      return true;
    }
    return false;
  }

  // List as FutureBuilder with WSLApi
  return FutureBuilder<List<String>>(
    future: SSHAPI().list(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<Widget> newList = [];
        List<String> list = snapshot.data ?? [];
        // Check if there are distros
        if (list.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text('Add a host so it will be shown here.'),
            ),
          );
        }
        for (String item in list) {
          newList.add(ListItem(item: item, statusMsg: statusMsg));
        }
        return Expanded(
          child: ListView.custom(
            childrenDelegate: SliverChildListDelegate(newList),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      // By default, show a loading spinner.
      return const Center(child: ProgressRing());
    },
  );
}
