import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/chart/scatter_chart/scatter_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/rendering/mouse_tracking.dart';

class ScatterChartLeaf extends StatelessWidget {
  const ScatterChartLeaf(
      {super.key, required this.data, required this.targetData});

  final ScatterChartData data;
  final ScatterChartData targetData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      final renderChart = RenderScatterChart(
        context,
        data,
        targetData,
        MediaQuery.of(context).textScaleFactor,
      )..mockTestSize = Size(constraints.maxWidth, constraints.maxHeight);
      final painter = RenderScatterChartPainter(renderChart);
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

class RenderScatterChartPainter extends CustomPainter {
  final RenderScatterChart render;

  RenderScatterChartPainter(this.render);

  @override
  void paint(Canvas canvas, Size size) {
    render.paint2(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// coverage:ignore-start

/// Low level ScatterChart Widget.
// class ScatterChartLeaf extends LeafRenderObjectWidget {
//   const ScatterChartLeaf({
//     super.key,
//     required this.data,
//     required this.targetData,
//   });

//   final ScatterChartData data;
//   final ScatterChartData targetData;

//   @override
//   RenderScatterChart createRenderObject(BuildContext context) =>
//       RenderScatterChart(
//         context,
//         data,
//         targetData,
//         MediaQuery.of(context).textScaleFactor,
//       );

//   @override
//   void updateRenderObject(
//     BuildContext context,
//     RenderScatterChart renderObject,
//   ) {
//     renderObject
//       ..data = data
//       ..targetData = targetData
//       ..textScale = MediaQuery.of(context).textScaleFactor
//       ..buildContext = context;
//   }
// }
// coverage:ignore-end

/// Renders our ScatterChart, also handles hitTest.
class RenderScatterChart extends RenderBaseChart<ScatterTouchResponse> {
  RenderScatterChart(
    BuildContext context,
    ScatterChartData data,
    ScatterChartData targetData,
    double textScale,
  )   : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(targetData.scatterTouchData, context);

  ScatterChartData get data => _data;
  ScatterChartData _data;

  set data(ScatterChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  ScatterChartData get targetData => _targetData;
  ScatterChartData _targetData;

  set targetData(ScatterChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.scatterTouchData);
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
  ScatterChartPainter painter = ScatterChartPainter();

  PaintHolder<ScatterChartData> get paintHolder {
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
  ScatterTouchResponse getResponseAtLocation(Offset localPosition) {
    final touchedSpot = painter.handleTouch(
      localPosition,
      mockTestSize ?? size,
      paintHolder,
    );
    return ScatterTouchResponse(touchedSpot);
  }

  @override
  // TODO: implement onHover
  PointerHoverEventListener? get onHover => throw UnimplementedError();
}
