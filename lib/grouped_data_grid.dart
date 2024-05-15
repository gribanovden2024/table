import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:table/table.dart';

class GroupedDataGrid extends StatefulWidget {
  const GroupedDataGrid(this.data, {super.key});

  final List<Map<String, dynamic>> data;

  @override
  State<GroupedDataGrid> createState() => _GroupedDataGridState();
}

class _GroupedDataGridState extends State<GroupedDataGrid> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SfDataGrid(
            source: DataSource(widget.data),
            columns: widget.data.first.keys.map((key) {

              return GridColumn(
                columnName: key,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }
    );
  }
}
