import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'data.dart';

class DataSource extends DataGridSource {
  final d = Data();
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
    int emptyCellCount = 0; // Количество пустых ячеек
    int emptyCellIndex = -1; // Индекс первой непустой ячейки

    for (int i = 0; i < row.getCells().length; i++) {
      if (row.getCells()[i].value.toString().isEmpty) {
        emptyCellCount++; // Увеличиваем количество пустых ячеек
      } else if (emptyCellIndex == -1) {
        emptyCellIndex = i; // Записываем индекс первой непустой ячейки
      }
    }

    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        bool isSingleNonEmpty =
            emptyCellCount > 0 && cell.value.toString().isNotEmpty;

        return Container(
          color: emptyCellIndex == 0 && emptyCellCount > 0
              ? Colors.yellow
              : emptyCellIndex == 1
                  ? Colors.grey
                  : Colors.white,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
              d.roundDoubleToString(cell.value),
              // cell.value.toString(),
              style: TextStyle(
                  fontWeight:
                      isSingleNonEmpty ? FontWeight.bold : FontWeight.normal,
                  color: Data().textColor(cell.value))),
        );
      }).toList(),
    );
  }
}
