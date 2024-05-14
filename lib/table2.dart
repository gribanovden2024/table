import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GroupedDataGrid extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> groupKeys;

  const GroupedDataGrid(
      {super.key, required this.data, required this.groupKeys});

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: groupKeys == [] || groupKeys.isEmpty
          ? DataSource(data)
          : GroupedDataSource(data: data, groupKeys: groupKeys),
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
              value: key == elements.first.keys.first ? groupKey : '',
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

class GroupedDataSource extends DataGridSource {
  GroupedDataSource({required this.data, required this.groupKeys});

  final List<Map<String, dynamic>> data;
  final List<String> groupKeys;

  @override
  List<DataGridRow> get rows => _groupAndSortData(data, groupKeys);

  List<DataGridRow> _groupAndSortData(
      List<Map<String, dynamic>> data, List<String> groupKeys) {
    if (groupKeys.isEmpty) return [];

    // Рекурсивная функция для группировки данных
    List<List<Map<String, dynamic>>> _groupData(
        List<Map<String, dynamic>> data, int index) {
      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var element in data) {
        String groupKey = element[groupKeys[index]].toString();
        if (!groupedData.containsKey(groupKey)) {
          groupedData[groupKey] = [];
        }
        groupedData[groupKey]!.add(element);
      }

      List<List<Map<String, dynamic>>> result = [];
      for (var key in groupedData.keys) {
        result.add(groupedData[key]!);
      }
      return result;
    }

    // Рекурсивная функция для построения строк данных
    List<DataGridRow> _buildRows(List<List<Map<String, dynamic>>> groups, int index) {
      List<DataGridRow> dataGridRows = [];

      for (var group in groups) {
        dataGridRows.add(DataGridRow(
          cells: [
            DataGridCell<String>(columnName: groupKeys[index], value: group.first[groupKeys[index]].toString()),
          ],
        ));

        if (index < groupKeys.length - 1) {
          var subGroups = _groupData(group, index + 1);
          var subRows = _buildRows(subGroups, index + 1);
          dataGridRows.addAll(subRows);
        } else {
          dataGridRows.addAll(group.map<DataGridRow>((element) {
            return DataGridRow(cells: element.entries.map<DataGridCell<dynamic>>((entry) {
              return DataGridCell<String>(columnName: entry.key, value: entry.value.toString());
            }).toList());
          }).toList());
        }
      }

      return dataGridRows;
    }

    // Начинаем группировку с первого уровня
    var groups = _groupData(data, 0);

    // Строим строки данных
    return _buildRows(groups, 0);
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
