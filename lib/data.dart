import 'dart:async' show Future;
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Data {
  late List<List<dynamic>>? csvTable;
  late List<Map<String, dynamic>> convertTabled;
  late List<DataGridRow> dataGridRowTabled;

  Future<List<Map<String, dynamic>>> getCsv() async {
    final csvString = await rootBundle.loadString('assets/data.csv');
    csvTable = CsvConverter().convert(csvString);
    convertTabled = convertTable(csvTable!);
    return convertTabled;
  }

  List<DataGridRow> convertDataGridRow(List<Map<String, dynamic>> data) {
    List<DataGridRow> result = [];
    for (var element in data) {
      List<DataGridCell> cells = [];
      element.forEach((key, value) {
        cells.add(DataGridCell(columnName: key, value: value));
      });
      result.add(DataGridRow(cells: cells));
    }
    dataGridRowTabled = result;
    return result;
  }

  List<String> getKeys(List<List<dynamic>>? data) {
    List<String> result = data![0].map((value) => value.toString()).toList();
    return result.sublist(1);
  }

  List<Map<String, dynamic>> convertTable(List<List<dynamic>> table) {
    List<Map<String, dynamic>> convertedTable = [];

    if (table.isNotEmpty) {
      List<dynamic> headers = table[0];

      for (int i = 1; i < table.length; i++) {
        Map<String, dynamic> rowMap = {};

        for (int j = 0; j < headers.length; j++) {
          if (table[i].length > j) {
            rowMap[headers[j].toString()] = table[i][j];
          } else {
            rowMap[headers[j].toString()] = '';
          }
        }
        convertedTable.add(rowMap);
      }
    }

    return convertedTable;
  }
}
