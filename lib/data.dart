import 'dart:async' show Completer, Future;
import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'app_theme.dart';

final d = Data();

class Data {
  late List<List<dynamic>>? csvTable;
  late List<Map<String, dynamic>> convertTabled;

  Future<List<Map<String, dynamic>>> loadCsvFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();
    await uploadInput.onChange.first;
    html.File file = uploadInput.files!.first;
    final reader = html.FileReader();
    final completer = Completer<String>();
    reader.onLoadEnd
        .listen((event) => completer.complete(reader.result as String));
    reader.readAsText(file);
    String csvString = await completer.future;
    final csvTable = CsvConverter().convert(csvString);
    return convertTable(csvTable);
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
      required List<String> groupKeys,
      required List<String> sumKeys,
      required int index}) {
    final List<String> column = [];
    for (int i = 0; i < groupKeys.length; i++) {
      column.add('xlevel${i + 1}');
    }
    column.addAll(sumKeys);

    Map<String, List<Map<String, dynamic>>> groupedTable =
        groupBy(table, (obj) => obj[groupKeys[index]]);
    List<Map<String, dynamic>> sortedTable = [];

    for (var element in table) {
      String groupKey = element[groupKeys[index]].toString();

      if (!groupedTable.containsKey(groupKey)) {
        groupedTable[groupKey] = [];
      }
      groupedTable[groupKey]!.add(element);
    }

    groupedTable.forEach((keyGroup, valueGroup) {
      Map<String, dynamic> firstEntry = {};

      double sum = 0;

      for (var key in column) {
        if (sumKeys.contains(key)) {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          for (int i = 0; i < index + 1; i++) {
            sum = sum / 2;
          }
          firstEntry[key] = sum;
        } else {
          firstEntry[key] = key == column.elementAt(index) ? keyGroup : '';
        }
      }
      sortedTable.add(firstEntry);

      if (groupKeys.length - 1 > index) {
        sortedTable.addAll(sortTable(
            table: valueGroup,
            groupKeys: groupKeys,
            sumKeys: sumKeys,
            index: index + 1));
      } else {
        for (var element in valueGroup) {
          Map<String, dynamic> sortedRow = {};
          for (var key in column) {
            sortedRow[key] = element[key] ?? '';
          }
          if (!sortedTable.contains(sortedRow)) {
            sortedTable.add(sortedRow);
          }
        }
      }
    });
    sortedTable = removeDuplicates(sortedTable, groupKeys.length);
    sortedTable = removeEmptyEntries(sortedTable, groupKeys.length);
    return sortedTable.toSet().toList();
  }

  List<Map<String, dynamic>> removeEmptyEntries(
      List<Map<String, dynamic>> sortedTable, int length) {
    return sortedTable.where((entry) {
      for (int i = 0; i < length; i++) {
        if (entry[sortedTable.first.keys.elementAt(i)] != null &&
            entry[sortedTable.first.keys.elementAt(i)].toString().isNotEmpty) {
          return true; // Найдено непустое значение, сохраняем элемент
        }
      }
      return false; // Все значения пустые, удаляем элемент
    }).toList();
  }

  List<Map<String, dynamic>> removeDuplicates(
      List<Map<String, dynamic>> sortedTable, int i) {
    final uniqueEntries = <String>{};
    final uniqueSortedTable = <Map<String, dynamic>>[];

    for (var entry in sortedTable) {
      int emptyValueCount =
          entry.values.where((value) => value.toString().isEmpty).length;
      final entryJson = jsonEncode(entry);
      (emptyValueCount == i)
          ? {
              if (uniqueEntries.add(entryJson)) {uniqueSortedTable.add(entry)}
            }
          : uniqueSortedTable.add(entry);
    }

    return uniqueSortedTable;
  }

  Color textColor(dynamic data) {
    return (data is String &&
                double.tryParse(data) != null &&
                double.tryParse(data)! < 0) ||
            (data is num && data < 0)
        ? Colors.red
        : Colors.black;
  }

  String roundDoubleToString(String value, int i) {
    return (double.tryParse(value) == null)
        ? value
        : ((double.tryParse(value)! * pow(10, i)).round() / pow(10, i))
            .toString();
  }

  Color colorRow(int index, dynamic data) {
    return index == 0 && data.first.keys.first == 'xlevel1'
        ? AppTheme.xlevel1
        : index == 1
            ? AppTheme.xlevel2
            : Colors.white;
  }

  TextStyle textRow(int index, dynamic value) {
    return TextStyle(
      fontSize: 12,
      fontWeight: (index == 0 || index == 1 || index == 2)
          ? FontWeight.bold
          : FontWeight.normal,
      fontStyle: index == 3 ? FontStyle.italic : FontStyle.normal,
      color: Data().textColor(value),
    );
  }
}
