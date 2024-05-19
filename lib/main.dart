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
  final List<String> _allKeys = [];
  final List<String> _sumKeys = [];
  final List<String> _groupKeys = [];
  final List<Map<String, dynamic>> _data = [];
  final List<Map<String, dynamic>> _groupedData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          listAll(),
          const VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                list(_groupKeys),
                const Divider(),
                list(_sumKeys),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: barRow(),
    );
  }

  Row barRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ElevatedButton(
        onPressed: () async {
          final data = await d.loadCsvFile();
          setState(() {
            cleaner();
            _data.addAll(data);
            _allKeys.addAll(d.getKeys(_data).first.isEmpty
                ? d.getKeys(_data).sublist(1)
                : d.getKeys(_data));
          });
        },
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(300, 50)),
          textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14)),
        ),
        child: const Text('Выбрать файл'),
      ),
      ElevatedButton(
        onPressed: () {
          if (_groupKeys.isNotEmpty && _groupKeys != []) {
            createTable();
          }
          _tableWindow(
              context,
              _groupKeys.isEmpty || _groupKeys == [] ? _data : _groupedData,
              _groupKeys);
        },
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(300, 50)),
          textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14)),
        ),
        child: const Text('Построить'),
      ),
    ],
  );

  Expanded listAll() => Expanded(
    child: ReorderableListView(
      children: _allKeys
          .map((item) => ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        key: Key(item),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: Icon(_sumKeys.contains(item)
                  ? Icons.summarize
                  : Icons.summarize_outlined),
              onTap: () => setState(() => _sumKeys.contains(item)
                    ? _sumKeys.remove(item)
                    : {
                  _sumKeys.add(item),
                  if (_groupKeys.contains(item))
                    _groupKeys.remove(item)
                }),
            )
          ],
        ),
        title: Text(item),
        selectedColor: Colors.green,
        selected: _groupKeys.contains(item),
        onTap: () => setState(() => _groupKeys.contains(item)
              ? _groupKeys.remove(item)
              : {
            _groupKeys.add(item),
            if (_sumKeys.contains(item)) _sumKeys.remove(item)
          }),
      ))
          .toList(),
      onReorder: (oldIndex, newIndex) => setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _allKeys.removeAt(oldIndex);
          _allKeys.insert(newIndex, item);
        }),
    ),
  );

  Expanded list(List<String> keys) => Expanded(
    child: ReorderableListView(
      children: keys
          .map((item) => ListTile(
        key: Key(item),
        title: Text(item),
        onTap: () => setState(() => keys.remove(item)),
      ))
          .toList(),
      onReorder: (oldIndex, newIndex) => setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = keys.removeAt(oldIndex);
          keys.insert(newIndex, item);
        }),
    ),
  );

  void createTable() {
    _groupedData.clear();
    _groupedData.addAll(d.sortTable(
        table: _data, groupKeys: _groupKeys, sumKeys: _sumKeys, index: 0));
  }

  void _tableWindow(context, List<Map<String, dynamic>> data,
      List<String> groupKeys) => showDialog(
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
            body: DynamicDataTable(data: data),
          ),
        );
      },
    );

  void cleaner() {
    _allKeys.clear();
    _sumKeys.clear();
    _groupKeys.clear();
    _groupedData.clear();
  }
}