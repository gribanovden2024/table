import 'package:flutter/cupertino.dart';

import 'app_theme.dart';
import 'data.dart';

class DynamicDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const DynamicDataTable({super.key, required this.data});

  @override
  State<DynamicDataTable> createState() => _DynamicDataTableState();
}

class _DynamicDataTableState extends State<DynamicDataTable> {
  late List<Map<String, dynamic>> _data;
  late int _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _hoveredRowIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    final d = Data();
    if (_data.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: _data.length + 1,
        itemBuilder: (context, index) {
          return MouseRegion(
            onEnter: (_) {
              setState(() {
                _hoveredRowIndex = index;
              });
            },
            onExit: (_) {
              setState(() {
                _hoveredRowIndex = -1;
              });
            },
            child: IntrinsicHeight(
              child: Row(
                children: _data.first.keys.map((column) {
                  int emptyCellIndex = -1;

                  for (int i = 0; i < _data.first.keys.length; i++) {
                    if (index > 0 &&
                        _data[index - 1]['xlevel${i + 1}']
                            .toString()
                            .isNotEmpty) {
                      emptyCellIndex = i;
                      break;
                    }
                  }

                  // Объединяем ячейки
                  if (RegExp(r'^xlevel[1-9]$').hasMatch(column)) {
                    if (column == 'xlevel1') {
                      // Объединение ячеек с ключами 'xlevel1' до 'xlevel9'
                      return Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _hoveredRowIndex == index && index != 0
                                  ? AppTheme.xlevel1
                                  : d.colorRow(index == 0 ? 1 : emptyCellIndex),
                              border: Border.all(color: AppTheme.xlevel2),
                            ),
                            padding: const EdgeInsets.all(1.0),
                            child: Align(
                              alignment: index == 0
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: emptyCellIndex >= 0
                                        ? emptyCellIndex * 50.0
                                        : 0),
                                child: Text(
                                  index == 0
                                      ? 'Расшифровка'
                                      : _combineCellsContent(index - 1),
                                  style: index == 0
                                      ? const TextStyle()
                                      : d.textRow(emptyCellIndex,
                                          _combineCellsContent(index - 1)),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Пустое пространство для объединённых ячеек
                    }
                  } else {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _hoveredRowIndex == index && index != 0
                                ? AppTheme.xlevel1
                                : d.colorRow(index == 0 ? 1 : emptyCellIndex),
                            border: Border.all(color: AppTheme.xlevel2),
                          ),
                          padding: const EdgeInsets.all(1.0),
                          child: Align(
                            alignment: index == 0
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: Text(
                              index == 0
                                  ? column.toString()
                                  : d.roundDoubleToString(
                                      _data[index - 1][column]?.toString()),
                              style: index == 0
                                  ? const TextStyle()
                                  : d.textRow(emptyCellIndex,
                                      _data[index - 1][column]?.toString()),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _combineCellsContent(int rowIndex) => _data.first.keys
      .map((key) => RegExp(r'^xlevel[1-9]$').hasMatch(key)
          ? _data[rowIndex][key]?.toString()
          : '')
      .join(' ');
}
