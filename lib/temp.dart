import 'package:flutter/material.dart';
import 'data.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _firstList = [];
  List<String> _secondList = [];
  List<Map<String, dynamic>> groupedData = [];
  final d = Data();

  @override
  void initState() {
    super.initState();
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
        onPressed: () async {
          groupedData = await d.getCsv();
          _showBottomSheet(context, d.groupListByKeys(groupedData, _secondList));
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

void _showBottomSheet(BuildContext context, function) {
  List<Map<String, dynamic>> groupedData = function();
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView(
        children: [
          Center(
            child: DataTableWidget(groupedData),
          ),
        ],
      );
    },
  );
}

class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> table;

  const DataTableWidget(this.table, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (table.isEmpty) {
      return const Text('Table is empty');
    }

    List<DataColumn> columns = [];
    List<DataRow> rows = [];

    // Создаем столбцы таблицы на основе ключей первого элемента
    for (var key in table.first.keys) {
      columns.add(DataColumn(label: Text(key)));
    }

    // Создаем строки таблицы на основе данных
    for (var row in table) {
      List<DataCell> cells = [];
      row.forEach((key, value) {
        cells.add(DataCell(Text(value.toString())));
      });
      rows.add(DataRow(cells: cells));
    }

    // Возвращаем виджет DataTable с созданными столбцами и строками
    return DataTable(columns: columns, rows: rows);
  }
}
