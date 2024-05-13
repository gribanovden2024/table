import 'dart:async' show Future;
import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class Data {
  late List<List<dynamic>>? csvTable;

  Future<List<String>> readCSV() async {
    final csvString = await rootBundle.loadString('assets/data.csv');
    csvTable = CsvConverter().convert(csvString);
    List<String> result =
        csvTable![0].map((value) => value.toString()).toList();
    return result.sublist(1);
  }

  List<Map<String, dynamic>> convertList(
      List<List<dynamic>> inputList, List<String> keys) {
    List<Map<String, dynamic>> outputList = [];

    for (var innerList in inputList) {
      Map<String, dynamic> map = {};
      innerList.asMap().forEach((index, value) {
        map[keys[index]] = value;
      });
      outputList.add(map);
    }

    return outputList;
  }

  Map<dynamic, dynamic> groupByKeys(List<String> keys) {
    // Создаем итоговую карту для хранения результатов группировки
    var groupedData = <dynamic, dynamic>{};

    // Создаем ключ группы, состоящий из значений объекта для указанных ключей
    var groupKey = keys.map((key) => convertList(csvTable!,keys)[key]).toList();

    // Записываем объект данных в итоговую карту с ключом, сформированным из значений для указанных ключей
    groupedData[groupKey] = data;

    return groupedData;
  }
}
