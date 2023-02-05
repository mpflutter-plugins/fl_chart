import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/chart/radar_chart/radar_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/rendering/mouse_tracking.dart';

class RadarChartLeaf extends StatelessWidget {
  const RadarChartLeaf(
      {super.key, required this.data, required this.targetData});

  final RadarChartData data;
  final RadarChartData targetData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      final renderChart = RenderRadarChart(
        context,
        data,
        targetData,
        MediaQuery.of(context).textScaleFactor,
      )..mockTestSize = Size(constraints.maxWidth, constraints.maxHeight);
      final painter = RenderRadarChartPainter(renderChart);
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

class RenderRadarChartPainter extends CustomPainter {
  final RenderRadarChart render;

  RenderRadarChartPainter(this.render);

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

/// Low level RadarChart Widget.
// class RadarChartLeaf extends LeafRenderObjectWidget {
//   const RadarChartLeaf({
//     super.key,
//     required this.data,
//     required this.targetData,
//   });

//   final RadarChartData data;
//   final RadarChartData targetData;

//   @override
//   RenderRadarChart createRenderObject(BuildContext context) => RenderRadarChart(
//         context,
//         data,
//         targetData,
//         MediaQuery.of(context).textScaleFactor,
//       );

//   @override
//   void updateRenderObject(BuildContext context, RenderRadarChart renderObject) {
//     renderObject
//       ..data = data
//       ..targetData = targetData
//       ..textScale = MediaQuery.of(context).textScaleFactor
//       ..buildContext = context;
//   }
// }
// coverage:ignore-end

/// Renders our RadarChart, also handles hitTest.
class RenderRadarChart extends RenderBaseChart<RadarTouchResponse> {
  RenderRadarChart(
    BuildContext context,
    RadarChartData data,
    RadarChartData targetData,
    double textScale,
  )   : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(targetData.radarTouchData, context);

  RadarChartData get data => _data;
  RadarChartData _data;

  set data(RadarChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  RadarChartData get targetData => _targetData;
  RadarChartData _targetData;

  set targetData(RadarChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.radarTouchData);
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
  RadarChartPainter painter = RadarChartPainter();

  PaintHolder<RadarChartData> get paintHolder {
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
  RadarTouchResponse getResponseAtLocation(Offset localPosition) {
    final touchedSpot = painter.handleTouch(
      localPosition,
      mockTestSize ?? size,
      paintHolder,
    );
    return RadarTouchResponse(touchedSpot);
  }

  @override
  // TODO: implement onHover
  PointerHoverEventListener? get onHover => throw UnimplementedError();
}
