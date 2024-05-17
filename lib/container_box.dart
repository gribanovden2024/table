import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data.dart';

class ResizableContainer extends StatefulWidget {
  final int emptyCellIndex;
  final int index;
  final String column;
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>) onUpdate;

  const ResizableContainer(
      this.emptyCellIndex, this.index, this.column, this.data, this.onUpdate,
      {super.key});

  @override
  State<ResizableContainer> createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  double _width = 200.0;
  final d = Data();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _width += details.delta.dx;
          });
        },
        onPanEnd: (details) {
          // После окончания перемещения, вызываем onUpdate, чтобы передать новые данные
          widget.onUpdate({
            widget.column: _width, // Передаем ширину как новое значение
          });
        },
        child: Container(
          width: _width,
          decoration: BoxDecoration(
              color: d.colorRow(widget.emptyCellIndex),
              border: Border.all(color: AppTheme.xlevel2)),
          padding: const EdgeInsets.all(1.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.index == 0
                  ? widget.column.toString()
                  : d.roundDoubleToString(
                  widget.data[widget.index - 1][widget.column]?.toString()) ??
                      '',
              style: widget.index == 0
                  ? const TextStyle()
                  : d.textRow(widget.emptyCellIndex,
                  widget.data[widget.index - 1][widget.column]?.toString()),
            ),
          ),
        ));
  }
}
