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
    // Подсчитываем количество непустых значений в строке и находим индекс непустой ячейки
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
          child: Text(
            cell.value.toString(),
            style: isSingleNonEmpty
                ? const TextStyle(fontWeight: FontWeight.bold)
                : const TextStyle(),
          ),
        );
      }).toList(),
    );
  }
}
