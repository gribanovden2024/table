import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GroupedDataSource2 extends DataGridSource {
  GroupedDataSource2({required this.data, required this.groupKeys});

  List<Map<String, dynamic>> data;
  List<String> groupKeys;

  @override
  List<DataGridRow> get rows => _groupAndSortData(data, groupKeys);

  List<DataGridRow> _groupAndSortData(
      List<Map<String, dynamic>> data, List<String> groupKeys) {
    var groupedData = <String, List<Map<String, dynamic>>>{};

    var dataGridRows = <DataGridRow>[];

    for (var element in data) {
      String groupKey = element[groupKeys[0]].toString();
      if (!groupedData.containsKey(groupKey)) {
        groupedData[groupKey] = [];
      }
      groupedData[groupKey]!.add(element);
    }

    groupedData.forEach((groupKey, elements) {
      dataGridRows.add(
        DataGridRow(
          cells: elements.first.keys.map((key) {
            return DataGridCell<String>(
              columnName: key,
              value: key == elements.first.keys.elementAt(0) ? groupKey : '',
            );
          }).toList(),
        ),
      );

      dataGridRows.addAll(elements.map<DataGridRow>((element) {
        return DataGridRow(
          cells: element.entries.map((entry) {
            return DataGridCell<String>(
              columnName: entry.key,
              value: entry.value.toString(),
            );
          }).toList(),
        );
      }).toList());
    });

    return dataGridRows;
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

List<Map<String, dynamic>> groupAndSortData(
    List<Map<String, dynamic>> data, List<String> groupKeys) {
  data.sort((a, b) => a[groupKeys[0]].compareTo(b[groupKeys[0]]));

  List<Map<String, dynamic>> result = [];

  for (var i = 0; i < data.length; i++) {
    if (i == 0 || data[i][groupKeys[0]] != data[i - 1][groupKeys[0]]) {
      result.add({'groupHeader': data[i][groupKeys[0]]});
    }
    result.add(data[i]);
  }

  for (var i = 0; i < result.length; i++) {
    if (result[i]['groupHeader'] != null) {
      int start = i + 1;
      int end = i + 1;
      while (end < result.length && result[end]['groupHeader'] == null) {
        end++;
      }

      result
          .sublist(start, end)
          .sort((a, b) => a[groupKeys[1]].compareTo(b[groupKeys[1]]));

      i = end - 1;
    }
  }

  return result;
}

class GroupedDataSource3 extends DataGridSource {
  GroupedDataSource3(
      List<Map<String, dynamic>> _data, List<String> groupsKeys) {
    List<Map<String, dynamic>> data = groupAndSortData(_data, groupsKeys);
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
