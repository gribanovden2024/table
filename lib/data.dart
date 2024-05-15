import 'dart:async' show Completer, Future;
import 'package:collection/collection.dart';
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:html' as html;

class Data {
  late List<List<dynamic>>? csvTable;
  late List<Map<String, dynamic>> convertTabled;
  late List<DataGridRow> dataGridRowTabled;

  Future<List<Map<String, dynamic>>> getCsv(String? filePath) async {
    final csvString = await rootBundle.loadString('assets/data.csv');
    csvTable = CsvConverter().convert(csvString);
    convertTabled = convertTable(csvTable!);
    return convertTabled;
  }

  Future<List<Map<String, dynamic>>> loadCsvFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    await uploadInput.onChange.first;

    html.File file = uploadInput.files!.first;

    final reader = html.FileReader();
    final completer = Completer<String>();

    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as String);
    });

    reader.readAsText(file);

    String csvString = await completer.future;

    final csvTable = CsvConverter().convert(csvString);
    final convertedTable = convertTable(csvTable);

    return convertedTable;
  }

  List<String> getKeys(List<Map<String, dynamic>>? data) {
    if (data == null || data.isEmpty) {
      throw ArgumentError("Data cannot be null or empty");
    }

    return data[0].keys.map((e) => e.toString()).toList();
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

  List<Map<String, dynamic>> sortTable(
      {required List<Map<String, dynamic>> table,
      required List<String> selectKeys,
      required List<String> allKeys,
      required int index}) {
    Map<dynamic, List<Map<String, dynamic>>> groupedTable =
        groupBy(table, (obj) => obj[selectKeys[index]]);

    List<Map<String, dynamic>> sortedTable = [];
    for (var element in table) {
      String groupKey = element[selectKeys[index]].toString();
      if (!groupedTable.containsKey(groupKey)) {
        groupedTable[groupKey] = [];
      }
      groupedTable[groupKey]!.add(element);
    }
    groupedTable.forEach((groupKey, value) {
      // Добавляем элемент с заголовком группы
      Map<String, dynamic> firstEntry = {};
      for (var key in value.first.keys) {
        firstEntry[key] =
            key == value.first.keys.elementAt(index) ? groupKey : '';
      }
      sortedTable.add(firstEntry);

      // Добавляем все строки из элемента value с этим ключом
      if (selectKeys.length - 1 > index) {
        sortedTable.addAll(sortTable(
            table: value,
            selectKeys: selectKeys,
            allKeys: allKeys,
            index: index + 1));
      } else {
        sortedTable.addAll(value);
      }
    });

    return sortedTable.toSet().toList();
  }
}
