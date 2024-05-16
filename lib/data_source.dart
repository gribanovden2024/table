import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'app_theme.dart';
import 'data.dart';

class DataSource extends DataGridSource {
  final d = Data();
  int i;

  DataSource(List<Map<String, dynamic>> data, this.i) {
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
    int emptyCellCount = 0;
    int emptyCellIndex = -1;

    for (int i = 0; i < row.getCells().length; i++) {
      if (row.getCells()[i].value.toString().isEmpty) {
        emptyCellCount++;
      } else if (emptyCellIndex == -1) {
        emptyCellIndex = i;
      }
    }

    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        bool isSingleNonEmpty =
            emptyCellCount > i && cell.value.toString().isNotEmpty;

        return Container(
          color: emptyCellIndex == 0 && emptyCellCount >= 1
              ? AppTheme.xlevel1
              : emptyCellIndex == 1 && emptyCellCount >= 1
                  ? AppTheme.xlevel2
                  : Colors.white,
          padding: const EdgeInsets.all(2.0),
          alignment: Alignment.centerLeft,
          child: Text(
            d.roundDoubleToString(cell.value),
            style: TextStyle(
                fontSize: 12,
                fontWeight: emptyCellCount > 0 &&
                        (emptyCellIndex == 0 ||
                            emptyCellIndex == 1 ||
                            emptyCellIndex == 2)
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontStyle: emptyCellCount > 0 && emptyCellIndex == 3
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: Data().textColor(cell.value),
            ),

            // TextStyle(
            //     fontWeight:
            //         isSingleNonEmpty ? FontWeight.bold : FontWeight.normal,
            //     color: Data().textColor(cell.value)),
          ),
        );
      }).toList(),
    );
  }
}
