import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:table/table2.dart';

class GroupedDataGrid extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> groupKeys;

  const GroupedDataGrid(
      {super.key, required this.data, required this.groupKeys});

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: /*groupKeys == [] || groupKeys.isEmpty
          ? */DataSource(data)/*
          : GroupedDataSource2(data: data, groupKeys: groupKeys)*/,
          // : GroupedDataSource2(data: data, groupKeys: groupKeys),
      columns: data.first.keys.map((key) {
        return GridColumn(
          columnName: key,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}