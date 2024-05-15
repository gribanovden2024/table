import 'package:flutter/material.dart';
import 'data.dart';
import 'grouped_data_grid.dart';

void main() => runApp(const MaterialApp(home: MyHomePage()));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _firstList = [];
  final List<String> _secondList = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> groupedData = [];
  final d = Data();

  void tap() => groupedData = d.sortTable(
      table: data, selectKeys: _secondList, allKeys: _firstList, index: 0);

  @override
  Widget build(BuildContext context) {
    List<String> allKeys = _firstList.isNotEmpty
        ? _firstList[0] == ''
            ? _firstList.sublist(1)
            : _firstList
        : [];
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: _firstList.isEmpty
                    ? Container()
                    : ListView.builder(
                        itemCount: allKeys.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(allKeys[index]),
                            selectedColor: Colors.red,
                            selected: _secondList.contains(allKeys[index]),
                            onTap: () => setState(() {
                              if (!_secondList.contains(allKeys[index])) {
                                _secondList.add(allKeys[index]);
                              }
                            }),
                          );
                        },
                      ),
          ),
          const VerticalDivider(),
          Expanded(
            child: ListView.builder(
              itemCount: _secondList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_secondList[index]),
                  onTap: () => setState(() {
                    _secondList.remove(_secondList[index]);
                  }),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () async {
              data = await d.loadCsvFile();
              setState(() {
                _firstList = d.getKeys(data);
                _secondList.clear();
              });
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(300, 50)),
              textStyle:
                  MaterialStateProperty.all(const TextStyle(fontSize: 14)),
            ),
            child: const Text('Выбрать файл'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_secondList.isNotEmpty && _secondList != []) {
                print('_secondList = $_secondList');
                tap();
              }
              _showBottomSheet(
                  context,
                  _secondList.isEmpty || _secondList == [] ? data : groupedData,
                  _secondList);
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(300, 50)),
              textStyle:
                  MaterialStateProperty.all(const TextStyle(fontSize: 14)),
            ),
            child: const Text('Построить'),
          ),
        ],
      ),
    );
  }
}

void _showBottomSheet(BuildContext context, List<Map<String, dynamic>> data,
    List<String> secondList) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: GroupedDataGrid(data),
        ),
      );
    },
  );
}
