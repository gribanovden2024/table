import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DynamicDataGrid extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> groupKeys;

  const DynamicDataGrid(
      {super.key, required this.data, required this.groupKeys});

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: groupKeys == [] || groupKeys.isEmpty
          ? DataSource(data)
          : GroupedDataSource(groupKeys: groupKeys, data: data),
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

class GroupedDataSource extends DataGridSource {
  GroupedDataSource(
      {required List<Map<String, dynamic>> data,
      required List<String> groupKeys}) {
    _dataGridRows = _groupData(data, groupKeys);
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  List<DataGridRow> _groupData(
      List<Map<String, dynamic>> data, List<String> groupKeys) {
    var groupedData = <Map<String, dynamic>>[];

    for (var element in data) {
      bool found = false;

      for (var groupedElement in groupedData) {
        if (groupKeys.every((key) => groupedElement[key] == element[key])) {
          found = true;
          break;
        }
      }
      if (!found) {
        groupedData.add(Map.from(element));
      }
    }

    return groupedData.map<DataGridRow>((map) {
      return DataGridRow(
        cells: map.entries.map((entry) {
          return DataGridCell<String>(
            columnName: entry.key,
            value: entry.value.toString(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}

class DataSource extends DataGridSource {
  DataSource(List<Map<String, dynamic>> data) {
    _dataGridRows = data.map<DataGridRow>((map) {
      return DataGridRow(
        cells: map.entries.map((entry) {
          return DataGridCell<dynamic>(
            columnName: entry.key,
            value: entry.value,
          );
        }).toList(),
      );
    }).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}
