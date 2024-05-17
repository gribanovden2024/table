import 'package:flutter/material.dart';
import 'container_box.dart';
import 'data.dart';
import 'dynamic_table.dart';
import 'grouped_data_grid.dart';

void main() => runApp(const MaterialApp(home: MyHomePage()));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> allKeys = [];
  final List<String> actualKeys = [];
  final List<String> summKeys = [];
  List<String> _firstList = [];
  final List<String> _secondList = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> groupedData = [];
  final d = Data();

  void cleaner() {
    allKeys.clear();
    actualKeys.clear();
    summKeys.clear();
    _firstList.clear();
    _secondList.clear();
    // data.clear();
    groupedData.clear();
  }

  void tap(List<String> _actualKeys) => groupedData = d.sortTable(
      table: data,
      selectKeys: _secondList,
      allKeys: d.sortListByAnotherList(actualKeys, allKeys) /*_actualKeys*/,
      summKeys: d.sortListByAnotherList(summKeys, allKeys) /*summKeys*/,
      index: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              child: _firstList.isEmpty
                  ? Container()
                  : ReorderableListView(
                      children: allKeys
                          .map((item) => ListTile(
                                key: Key(item),
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // GestureDetector(
                                    //         child: Icon(
                                    //             actualKeys.contains(item)
                                    //                 ? Icons.delete_outline
                                    //                 : Icons.add),
                                    //         onTap: () => setState(() {
                                    //           actualKeys.contains(item)
                                    //               ? actualKeys.remove(item)
                                    //               : actualKeys.add(item);
                                    //         }),
                                    //       ),
                                    actualKeys.contains(item)
                                        ? GestureDetector(
                                            child: Icon(summKeys.contains(item)
                                                ? Icons.summarize
                                                : Icons.summarize_outlined),
                                            onTap: () => setState(() {
                                              summKeys.contains(item)
                                                  ? summKeys.remove(item)
                                                  : summKeys.add(item);
                                            }),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                title: Text(item),
                                // tileColor: actualKeys.contains(item)
                                //     ? Colors.white
                                //     : Colors.grey,
                                selectedColor: Colors.green,
                                selected: _secondList.contains(item),
                                onTap: () => setState(() {
                                  _secondList.contains(item)
                                      ? _secondList.remove(item)
                                      : _secondList.add(item);
                                  actualKeys.contains(item)
                                      ? actualKeys.remove(item)
                                      : actualKeys.add(item);
                                }),
                              ))
                          .toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = allKeys.removeAt(oldIndex);
                          allKeys.insert(newIndex, item);
                        });
                      },
                    )),
          const VerticalDivider(),
          Expanded(
              child: ReorderableListView(
            children: _secondList
                .map((item) => ListTile(
                      key: Key(item),
                      title: Text(item),
                      onTap: () => setState(() {
                        _secondList.remove(item);
                      }),
                    ))
                .toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _secondList.removeAt(oldIndex);
                _secondList.insert(newIndex, item);
              });
            },
          )),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () async {
              data = await d.loadCsvFile();
              setState(() {
                cleaner();
                _firstList = d.getKeys(data);
                _firstList.isNotEmpty
                    ? allKeys.addAll(_firstList.sublist(1))
                    : allKeys.addAll(_firstList);
                actualKeys.addAll(allKeys);
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
                tap(d.sortListByAnotherList(actualKeys, allKeys));
              }
              _tableWindow(
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

void _tableWindow(BuildContext context, List<Map<String, dynamic>> data,
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
          body:
          // GroupedDataGrid(data,3),
          DynamicDataTable(data: data),
          // ResizableContainer(0,1,'cod1',[
          //   {'cod1':9}
          // ]),
        ),
      );
    },
  );
}
