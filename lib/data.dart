import 'dart:async' show Completer, Future;
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'app_theme.dart';

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
      required List<String> summKeys,
      required int index}) {
    List<String> actualKeys = [];
    for (int i = 0; i < selectKeys.length; i++) {
      actualKeys.add('xlevel${i + 1}');
    }
    actualKeys.addAll(summKeys);

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
      Map<String, dynamic> firstEntry = {};

      double sum = 0;

      for (var key in actualKeys /*allKeys*/) {
        if (summKeys.contains(key)) {
          sum = valueGroup.fold(
              0,
              (previous, element) =>
                  previous + (double.tryParse(element[key]) ?? 0));
          // firstEntry[key] = sum / (index > 0 ? index * 2 : 1) / 2;
          for (int i = 0; i<index+1;i++) {
            sum = sum/2;
          }
          firstEntry[key] = sum /*/ (2 ^ (index + 1))*/;
        } else {
          firstEntry[key] =
              key == actualKeys /*allKeys*/ .elementAt(index) ? keyGroup : '';
        }
      }
      sortedTable.add(firstEntry);

      if (selectKeys.length - 1 > index) {
        sortedTable.addAll(sortTable(
            table: valueGroup,
            selectKeys: selectKeys,
            allKeys: allKeys,
            summKeys: summKeys,
            index: index + 1));
      } else {
        for (var element in valueGroup) {
          Map<String, dynamic> sortedRow = {};
          for (var key in actualKeys /*allKeys*/) {
            sortedRow[key] = element[key] ?? '';
          }
          if (!sortedTable.contains(sortedRow)) {
            sortedTable.add(sortedRow);
          }
        }
      }
    });
    sortedTable = removeDuplicates(sortedTable, selectKeys.length);
    sortedTable = removeEmptyEntries(sortedTable);
    return sortedTable.toSet().toList();
  }

  List<Map<String, dynamic>> removeEmptyEntries(
      List<Map<String, dynamic>> sortedTable) {
    final List<String> selectKeys = [
      'xlevel1',
      'xlevel2',
      'xlevel3',
      'xlevel4',
      'xlevel5',
      'xlevel6',
      'xlevel7',
      'xlevel8',
      'xlevel9'
    ];
    return sortedTable.where((entry) {
      for (var key in selectKeys) {
        if (entry[key] != null && entry[key].toString().isNotEmpty) {
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
      // Check the number of empty values in the entry
      int emptyValueCount =
          entry.values.where((value) => value.toString().isEmpty).length;

      // Encode entry to JSON string
      final entryJson = jsonEncode(entry);

      // If entry has more empty values than 'i', check for uniqueness
      if (emptyValueCount == i) {
        if (uniqueEntries.add(entryJson)) {
          uniqueSortedTable.add(entry);
        }
      } else {
        // If empty values are less than or equal to 'i', add to uniqueSortedTable without checking for duplicates
        uniqueSortedTable.add(entry);
      }
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

  String roundDoubleToString(dynamic value) {
    double? val;
    if (value is String && double.tryParse(value) == null) {
      return value;
    } else {
      if (value is! num) {
        val = double.tryParse(value);
      } else {
        val = value as double?;
      }
      // Округляем число до трех знаков после запятой
      double rounded = double.parse(val!.toStringAsFixed(1));
      // Если результат равен исходному числу, возвращаем его в виде строки
      if (rounded == val) {
        return val.toString();
      }
      // Иначе, возвращаем округленное число в виде строки
      return rounded.toString();
    }
  }

  List<String> sortListByAnotherList(List<String> list1, List<String> list2) {
    final Map<String, int> indexMap = {
      for (int i = 0; i < list2.length; i++) list2[i]: i
    };

    list1.sort((a, b) {
      final indexA = indexMap[a] ?? list2.length;
      final indexB = indexMap[b] ?? list2.length;
      return indexA.compareTo(indexB);
    });

    return list1;
  }

  Color colorRow(int index) {
    return index == 0
      ? AppTheme.xlevel1
      : index == 1
          ? AppTheme.xlevel2
          : Colors.white;
  }

  TextStyle textRow(int index, dynamic value) {
    return TextStyle(
      fontSize: 12,
      fontWeight: /*emptyCellCount > 0 &&*/
          (index == 0 ||
              index == 1 ||
              index == 2)
          ? FontWeight.bold
          : FontWeight.normal,
      fontStyle: /*emptyCellCount > 0 && */index == 3
          ? FontStyle.italic
          : FontStyle.normal,
      color: Data().textColor(value),
    );
  }
}
