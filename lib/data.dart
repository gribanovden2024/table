import 'dart:async' show Future;
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class Data {
  late List<List<dynamic>>? csvTable;
  late List<Map<String, dynamic>> convertTabled;

  Future<List<Map<String, dynamic>>> getCsv() async {
    final csvString = await rootBundle.loadString('assets/data.csv');
    csvTable = CsvConverter().convert(csvString);
    convertTabled = convertTable(csvTable!);
    return convertTabled;
  }

  List<String> getKeys(List<List<dynamic>>? data) {
    List<String> result = data![0].map((value) => value.toString()).toList();
    return result.sublist(1);
  }

  List<Map<String, dynamic>> convertTable(List<List<dynamic>> table) {
    List<Map<String, dynamic>> convertedTable = [];

    if (table.isNotEmpty) {
      // Предполагаем, что первая строка содержит заголовки столбцов
      List<dynamic> headers = table[0];

      // Проходимся по строкам таблицы, начиная с индекса 1,
      // так как первая строка уже использована как заголовки столбцов
      for (int i = 1; i < table.length; i++) {
        Map<String, dynamic> rowMap = {};

        // Проходимся по элементам строки
        for (int j = 0; j < headers.length; j++) {
          // Если значение в строке присутствует, добавляем его в Map
          if (table[i].length > j) {
            rowMap[headers[j].toString()] = table[i][j];
          } else {
            // Если строка не содержит значения для столбца,
            // присваиваем пустую строку
            rowMap[headers[j].toString()] = '';
          }
        }
        convertedTable.add(rowMap);
      }
    }

    return convertedTable;
  }

  List<Map<String, dynamic>> groupListByKeys(List<Map<String, dynamic>> list, List<String> keys) {
    // Проверяем, что список и список ключей не пустые
    if (list.isEmpty || keys.isEmpty) {
      return [];
    }

    // Создаем карту для хранения сгруппированных данных
    Map<List<dynamic>, List<Map<String, dynamic>>> groupedData = {};

    // Проходимся по каждому элементу списка
    for (var item in list) {
      // Генерируем ключ для группировки, используя значения из элемента и ключи
      List<dynamic> groupKey = keys.map((key) {
        return item[key];
      }).toList();

      // Проверяем, есть ли уже группа с таким ключом
      if (!groupedData.containsKey(groupKey)) {
        // Если нет, создаем новую группу
        groupedData[groupKey] = [];
      }

      // Добавляем элемент в группу
      groupedData[groupKey]!.add(item);
    }

    // Сортируем группы по порядку ключей
    List<dynamic> sortedGroups = keys.map((key) {
      return list[0][key];
    }).toList();

    // Формируем сгруппированный список
    List<Map<String, dynamic>> groupedList = [];
    for (var groupKey in sortedGroups) {
      // Добавляем все элементы из группы в сгруппированный список
      groupedList.addAll(groupedData[groupKey]!);
    }

    return groupedList;
  }
}
