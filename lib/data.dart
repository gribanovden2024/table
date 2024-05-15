import 'dart:async' show Completer, Future;
import 'package:collection/collection.dart';
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:html' as html;

class Data {
  late List<List<dynamic>>? csvTable;
  late List<Map<String, dynamic>> convertTabled;
  late List<DataGridRow> dataGridRowTabled;

  // Future<List<Map<String, dynamic>>> getCsv(String? filePath) async {
  //   final csvString = await rootBundle.loadString('assets/data.csv');
  //   csvTable = CsvConverter().convert(csvString);
  //   convertTabled = convertTable(csvTable!);
  //   return convertTabled;
  // }

  Future<List<Map<String, dynamic>>> loadCsvFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
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
      required int index}) {
    Map<String, List<Map<String, dynamic>>> groupedTable =
        groupBy(table, (obj) => obj[selectKeys[index]]);
    List<Map<String, dynamic>> sortedTable = [];

    for (var element in table) {
      String groupKey = element[selectKeys[index]].toString();

      if (!groupedTable.containsKey(groupKey)) {
        groupedTable[groupKey] = [];
      }
      groupedTable[groupKey]!.add(element);
    }

    groupedTable.forEach((keyGroup, valueGroup) {
      // Добавляем элемент с заголовком группы
      Map<String, dynamic> firstEntry = {};

      // Инициализируем сумму для ключа 'xxdiv'
      double sum = 0;

      for (var key in valueGroup.first.keys) {
        if (key == 'xxdiv') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else if (key == 'xendSpent') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else if (key == 'timespent') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else if (key == 'estimateH') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else if (key == 'start_time_estimate') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else if (key == 'end_time_estimate') {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
        } else {
          firstEntry[key] =
              key == valueGroup.first.keys.elementAt(index) ? keyGroup : '';
        }
      }
      sortedTable.add(firstEntry);

      if (selectKeys.length - 1 > index) {
        sortedTable.addAll(sortTable(
            table: valueGroup, selectKeys: selectKeys, index: index + 1));
      } else {
        sortedTable.addAll(valueGroup);
      }
    });

    return sortedTable.toSet().toList();
  }

  Color textColor(dynamic data) {
    return (data is String &&
                double.tryParse(data) != null &&
                double.tryParse(data)! < 0) ||
            (data is num && data < 0)
        ? Colors.red
        : Colors.black;
  }

  String roundDoubleToString(dynamic value) {
    double? val;
    if (value is String && double.tryParse(value)==null) {
      return value;
    } else {
      if (value is! num) {
        val = double.tryParse(value);
      } else {
        val = value as double?;
      }
        // Округляем число до трех знаков после запятой
        double rounded = double.parse(val!.toStringAsFixed(3));
        // Если результат равен исходному числу, возвращаем его в виде строки
        if (rounded == val) {
          return val.toString();
        }
        // Иначе, возвращаем округленное число в виде строки
        return rounded.toString();

    }
  }
}
