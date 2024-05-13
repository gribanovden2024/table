import 'package:flutter/material.dart';

import 'data.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _firstList = [];
  final List<String> _secondList = [];
  final d = Data();

  @override
  void initState() {
    super.initState();
    // d.init();
    d.readCSV().then((list) => setState(() => _firstList = list));
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
                    onTap: () =>
                        setState(() => _secondList.add(_firstList[index])),
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
                    onTap: () =>
                        setState(() => _secondList.remove(_secondList[index])),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: ElevatedButton(
          onPressed: () => _showBottomSheet(context, d.groupByKeys(_secondList)),
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(const Size(300, 50)),
            textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14)),
          ),
          child: const Text('Построить'),
        ));
  }
}

void main() => runApp(const MaterialApp(home: MyHomePage()));

Future<void> _showBottomSheet(context, function) async {
  String groupedData = await function();
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView(
        children: [
          Center(
            child: TableWidget(groupedData: groupedData),
          ),
        ],
      );
    },
  );
}

class TableWidget extends StatelessWidget {
  final Map<dynamic, dynamic> groupedData;

  TableWidget({required this.groupedData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          DataTable(
            columns: <DataColumn>[
              DataColumn(label: Text('Key')),
              DataColumn(label: Text('Value')),
            ],
            rows: groupedData.entries
                .map(
                  (entry) => DataRow(
                    cells: <DataCell>[
                      DataCell(Text(entry.key.toString())),
                      DataCell(Text(entry.value.toString())),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
