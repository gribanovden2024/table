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
  late Map<String, double> _columnWidths;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _hoveredRowIndex = -1;

    _columnWidths = {
      for (var key in _data.first.keys) key: 100.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(slivers: [
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            minHeight: 50,
            maxHeight: 50,
            child: Row(
              children: _data.first.keys.map((column) {
                int emptyCellIndex = -1;

                if (RegExp(r'^xlevel[1-9]$').hasMatch(column)) {
                  if (column == 'xlevel1') {
                    return Expanded(
                      flex: 9,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.xlevel2,
                            border: Border.all(color: AppTheme.xlevel2),
                          ),
                          padding: const EdgeInsets.all(1.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: emptyCellIndex >= 0
                                      ? emptyCellIndex * 50.0
                                      : 0),
                              child: const Text(
                                'Расшифровка',
                                style: TextStyle(),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() => _columnWidths[column] = (_columnWidths[column]! -
                                  details.delta.dx)
                              .clamp(50.0, MediaQuery.of(context).size.width));
                      },
                      child: SizedBox(
                          width: _columnWidths[column],
                          child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.xlevel2,
                                    border: Border.all(color: AppTheme.xlevel2),
                                  ),
                                  padding: const EdgeInsets.all(1.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        column.toString(),
                                        style: const TextStyle(),
                                      ))))));
                }
              }).toList(),
            ),
          ),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredRowIndex = index),
                onExit: (_) => setState(() => _hoveredRowIndex = -1),
                child: IntrinsicHeight(
                  child: Row(
                    children: _data.first.keys.map((column) {
                      int emptyCellIndex = -1;

                      for (int i = 0; i < _data.first.keys.length; i++) {
                        if (index >= 0 &&
                            _data[index]['xlevel${i + 1}']
                                .toString()
                                .isNotEmpty) {
                          emptyCellIndex = i;
                          break;
                        }
                      }

                      if (RegExp(r'^xlevel[1-9]$').hasMatch(column)) {
                        if (column == 'xlevel1') {
                          return Expanded(
                            flex: 9,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _hoveredRowIndex ==
                                          index /*&& index != 0*/
                                      ? AppTheme.xlevel1
                                      : d.colorRow(emptyCellIndex, _data),
                                  border: Border.all(color: AppTheme.xlevel2),
                                ),
                                padding: const EdgeInsets.all(1.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: emptyCellIndex >= 0
                                            ? emptyCellIndex * 50.0
                                            : 0),
                                    child: Text(
                                      _combineCellsContent(index),
                                      style: d.textRow(emptyCellIndex,
                                          _combineCellsContent(index)),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return SizedBox(
                          width: _columnWidths[column],
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    _hoveredRowIndex == index /*&& index != 0*/
                                        ? AppTheme.xlevel1
                                        : d.colorRow(emptyCellIndex, _data),
                                border: Border.all(color: AppTheme.xlevel2),
                              ),
                              padding: const EdgeInsets.all(1.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  d.roundDoubleToString(
                                      _data[index][column]!.toString(), 1),
                                  style: d.textRow(emptyCellIndex,
                                      _data[index][column]?.toString()),
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
            childCount: _data.length,
          ),
        ),
      ]),
    );
  }

  String _combineCellsContent(int rowIndex) => _data.first.keys
      .map((key) => RegExp(r'^xlevel[1-9]$').hasMatch(key)
          ? _data[rowIndex][key]?.toString()
          : '')
      .join(' ');
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
