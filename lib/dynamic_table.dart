import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'container_box.dart';
import 'data.dart';

class DynamicDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const DynamicDataTable({super.key, required this.data});

  @override
  State<DynamicDataTable> createState() => _DynamicDataTableState();
}

class _DynamicDataTableState extends State<DynamicDataTable> {
  late List<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void updateData(int rowIndex, Map<String, dynamic> newData) {
    setState(() {
      _data[rowIndex] = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = Data();
    if (widget.data.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: widget.data.length + 1,
        itemBuilder: (context, index) {
          return IntrinsicHeight(
            child: Row(
              children: widget.data.first.keys.map((column) {
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
                // int emptyCellCount = 0;
                int emptyCellIndex = -1;

                for (int i = 0; i < selectKeys.length; i++) {
                  if (index >0&& widget.data[index-1][selectKeys[i]].toString().isNotEmpty) {
                    emptyCellIndex = i;
                    break;
                  }
                }
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: d.colorRow(index == 0 ?1 :emptyCellIndex),
                        border: Border.all(color: AppTheme.xlevel2)),
                    padding: const EdgeInsets.all(1.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(index == 0
                          ? column.toString()
                          : d.roundDoubleToString(_data[index - 1][column]?.toString()) ?? '',
                        style: index == 0 ?TextStyle() :d.textRow(emptyCellIndex, _data[index - 1][column]?.toString()),
                      ),
                    ),
                  ),
                );
                // return Expanded(
                //   child: ResizableContainer(
                //     emptyCellIndex,
                //     index,
                //     column,
                //     _data,
                //     (newData) {
                //       updateData(index - 1, newData);
                //     },
                //   ),
                // );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
