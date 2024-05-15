import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
    int nonEmptyCellCount = 0;
    int nonEmptyCellIndex = -1;

    for (int i = 0; i < row.getCells().length; i++) {
      if (row.getCells()[i].value.toString().isNotEmpty) {
        nonEmptyCellCount++;
        nonEmptyCellIndex = i;
      }
    }

    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        bool isSingleNonEmpty =
            nonEmptyCellCount == 1 && cell.value.toString().isNotEmpty;

        return Container(
          color: nonEmptyCellIndex == 0
              ? Colors.yellow
              : nonEmptyCellIndex == 1
                  ? Colors.grey
                  : Colors.white,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(cell.value.toString(),
              style: TextStyle(
                  fontWeight:
                      isSingleNonEmpty ? FontWeight.bold : FontWeight.normal,
                  color: double.tryParse(cell.value) != null &&
                          double.tryParse(cell.value)! < 0
                      ? Colors.red
                      : Colors.black)),
        );
      }).toList(),
    );
  }
}
