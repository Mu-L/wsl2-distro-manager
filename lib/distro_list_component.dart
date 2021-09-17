import 'api.dart';
import 'package:fluent_ui/fluent_ui.dart';

FutureBuilder<List<String>> distroList(WSLApi api, statusMsg(msg)) {
  return FutureBuilder<List<String>>(
    future: api.list(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<Widget> newList = [];
        List list = snapshot.data ?? [];
        for (String item in list) {
          newList.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              child: ListTile(
                title: Text(item),
                leading: IconButton(
                  icon: const Icon(FluentIcons.play),
                  onPressed: () {
                    print('pushed start ' + item);
                    api.start(item);
                  },
                ),
                trailing: Row(
                  children: [
                    IconButton(
                      icon: const Icon(FluentIcons.copy),
                      onPressed: () async {
                        print('pushed copy ' + item);
                        statusMsg(
                            'Copying ' + item + '. This might take a while...');
                        String result = await api.copy(item);
                        statusMsg('DONE: Copying ' + item + '.');
                      },
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.rename),
                      onPressed: () {
                        print('pushed rename ' + item);
                      },
                    ),
                    IconButton(
                        icon: const Icon(FluentIcons.delete),
                        onPressed: () {
                          print('pushed delete ' + item);
                          deleteDialog(context, item, api, statusMsg);
                        }),
                  ],
                ),
              ),
            ),
          ));
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
      return const ProgressRing();
    },
  );
}

deleteDialog(context, item, api, statusMsg(msg)) {
  showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: Text('Delete ' + item + ' permanently?'),
        content: const Text(
            'If you delete this Distro you won\'t be able to recover it. Do you want to delete it?'),
        actions: [
          Button(
              child: const Text('Delete'),
              style: ButtonStyle(
                backgroundColor: ButtonState.all(Colors.red),
                foregroundColor: ButtonState.all(Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                api.remove(item);
                statusMsg('DONE: Deleted ' + item + '.');
              }),
          Button(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      );
    },
  );
}
