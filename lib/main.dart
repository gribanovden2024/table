import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:table/table.dart';
import 'package:table/table2.dart';
// import 'package:table/table2.dart';
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
  List<Map<String, dynamic>> groupedData = [];
  final d = Data();

  Future<void> _initializeData() async {
    groupedData = await d.getCsv();
    setState(() {
      _firstList = d.getKeys(d.csvTable);
    });
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
        onPressed: () => _showBottomSheet(context, groupedData, _secondList),
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
          body: GroupedDataGrid(
            data: data, groupKeys: secondList
          ),
        ),
      );
    },
  );
}
