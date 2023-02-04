import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/mouse_tracking.dart';

// coverage:ignore-start

class LineChartLeaf extends StatelessWidget {
  const LineChartLeaf({
    super.key,
    required this.data,
    required this.targetData,
  });

  final LineChartData data;
  final LineChartData targetData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      final renderChart = RenderLineChart(
        context,
        data,
        targetData,
        MediaQuery.of(context).textScaleFactor,
      )..mockTestSize = Size(constraints.maxWidth, constraints.maxHeight);
      final painter = RenderLineChartPainter(renderChart);
      return GestureDetector(
        onPanDown: (details) {
          renderChart.notifyTouchEvent(FlPanDownEvent(details));
        },
        onPanStart: (details) {
          renderChart.notifyTouchEvent(FlPanStartEvent(details));
        },
        onPanUpdate: (details) {
          renderChart.notifyTouchEvent(FlPanUpdateEvent(details));
        },
        onPanEnd: (details) {
          renderChart.notifyTouchEvent(FlPanEndEvent(details));
        },
        onPanCancel: () {
          renderChart.notifyTouchEvent(FlPanCancelEvent());
        },
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: CustomPaint(
            painter: painter,
          ),
        ),
      );
    }));
  }
}

class RenderLineChartPainter extends CustomPainter {
  final RenderLineChart render;

  RenderLineChartPainter(this.render);

  @override
  void paint(Canvas canvas, Size size) {
    render.paint2(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Low level LineChart Widget.
// class LineChartLeaf extends LeafRenderObjectWidget {
//   const LineChartLeaf({
//     super.key,
//     required this.data,
//     required this.targetData,
//   });

//   final LineChartData data;
//   final LineChartData targetData;

//   @override
//   RenderLineChart createRenderObject(BuildContext context) => RenderLineChart(
//         context,
//         data,
//         targetData,
//         MediaQuery.of(context).textScaleFactor,
//       );

//   @override
//   void updateRenderObject(BuildContext context, RenderLineChart renderObject) {
//     renderObject
//       ..data = data
//       ..targetData = targetData
//       ..textScale = MediaQuery.of(context).textScaleFactor
//       ..buildContext = context;
//   }
// }
// coverage:ignore-end

/// Renders our LineChart, also handles hitTest.
class RenderLineChart extends RenderBaseChart<LineTouchResponse> {
  RenderLineChart(
    BuildContext context,
    LineChartData data,
    LineChartData targetData,
    double textScale,
  )   : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(
          targetData.lineTouchData,
          context,
        );

  LineChartData get data => _data;
  LineChartData _data;
  set data(LineChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  LineChartData get targetData => _targetData;
  LineChartData _targetData;
  set targetData(LineChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.lineTouchData);
    markNeedsPaint();
  }

  double get textScale => _textScale;
  double _textScale;
  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
  }

  // We couldn't mock [size] property of this class, that's why we have this
  @visibleForTesting
  Size? mockTestSize;

  @visibleForTesting
  LineChartPainter painter = LineChartPainter();

  PaintHolder<LineChartData> get paintHolder {
    return PaintHolder(data, targetData, textScale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    painter.paint(
      buildContext,
      CanvasWrapper(canvas, mockTestSize ?? size),
      paintHolder,
    );
    canvas.restore();
  }

  void paint2(Canvas canvas2, Offset offset) {
    final canvas = canvas2
      ..save()
      ..translate(offset.dx, offset.dy);
    painter.paint(
      buildContext,
      CanvasWrapper(canvas, mockTestSize ?? size),
      paintHolder,
    );
    canvas.restore();
  }

  @override
  LineTouchResponse getResponseAtLocation(Offset localPosition) {
    final touchedSpots = painter.handleTouch(
      localPosition,
      mockTestSize ?? size,
      paintHolder,
    );
    return LineTouchResponse(touchedSpots);
  }

  @override
  // TODO: implement onHover
  PointerHoverEventListener? get onHover => throw UnimplementedError();
}
