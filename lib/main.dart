import 'package:flutter/material.dart';
import 'data.dart';
import 'dynamic_table.dart';

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
      allKeys: d.sortListByAnotherList(actualKeys, allKeys),
      summKeys: summKeys,
      index: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              child: _firstList.isEmpty
                  ? Container()
                  : listAll()),
          const VerticalDivider(),
          Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: listGroup(),
                  ),
                  const Divider(),
                  Expanded(
                    child: listSumm(),
                  ),
                ],
              ),),
        ],
      ),
      bottomNavigationBar: barRow(),
    );
  }

  Row barRow() {
    return Row(
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
    );
  }
  ReorderableListView listAll() => ReorderableListView(
      children: allKeys
          .map((item) => ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        key: Key(item),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  ReorderableListView listGroup() =>ReorderableListView(
    children: _secondList
        .map((item) => ListTile(
      key: Key(item),
      title: Text(item),
      onTap: () => setState(() {
        _secondList.remove(item);
        actualKeys.add(item);
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
  );
  ReorderableListView listSumm() =>ReorderableListView(
    children: summKeys
        .map((item) => ListTile(
      key: Key(item),
      title: Text(item),
      onTap: () => setState(() {
        summKeys.remove(item);
      }),
    ))
        .toList(),
    onReorder: (oldIndex, newIndex) {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = summKeys.removeAt(oldIndex);
        summKeys.insert(newIndex, item);
      });
    },
  );
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
          DynamicDataTable(data: data),
        ),
      );
    },
  );
}
