import 'package:flutter/material.dart';
import 'data.dart';
import 'grouped_data_grid.dart';

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

  Future<void> _initializeData() async {
    data = await d.getCsv();
    setState(() {
      _firstList = d.getKeys(d.csvTable);
    });
  }

  void tap() {
    groupedData = d.sortTable(
        table: data, selectKeys: _secondList, allKeys: _firstList, index: 0);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    d.getCsv().then((_) {
      setState(() {
        _firstList = d.getKeys(d.csvTable);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _firstList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_firstList[index]),
                  onTap: () => setState(() {
                    _secondList.add(_firstList[index]);
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
      bottomNavigationBar: ElevatedButton(
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
          textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14)),
        ),
        child: const Text('Построить'),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: MyHomePage()));

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
          body: GroupedDataGrid(data: data, groupKeys: secondList),
        ),
      );
    },
  );
}
