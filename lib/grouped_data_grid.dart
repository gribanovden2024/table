import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:table/data_source.dart';

class GroupedDataGrid extends StatefulWidget {
  const GroupedDataGrid(this.data, this.i, {super.key});

  final List<Map<String, dynamic>> data;
  final int i;

  @override
  State<GroupedDataGrid> createState() => _GroupedDataGridState();
}

class _GroupedDataGridState extends State<GroupedDataGrid> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Устанавливаем фиксированную ширину для каждой колонки (например, 100)
      // double columnWidth = 100.0;
      // Общая ширина таблицы
      // double tableWidth = columnWidth * widget.data.first.keys.length;

      // Рассчитываем ширину для контейнера
      // double width =
      //     tableWidth > constraints.maxWidth ? constraints.maxWidth : tableWidth;

      return SizedBox(
        // width: width,
        child: SfDataGrid(
          headerRowHeight: 20,
          columnWidthMode: ColumnWidthMode.auto,
          source: DataSource(widget.data, widget.i),
          rowHeight: 20,
          columns: widget.data.first.keys.map((key) {
            return GridColumn(
              columnName: key,
              label: Container(
                padding: const EdgeInsets.all(2.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  key,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              // width: columnWidth,
            );
          }).toList(),
        ),
      );
    });
  }
}
