library transformable_frame;

import 'package:flutter/material.dart';

class TransformableFrame extends StatefulWidget {
  final Widget child;
  final ValueChanged<void> onCloseTap;
  final double height;
  final double width;
  final bool showHandlers;

  TransformableFrame({
    @required this.child,
    this.onCloseTap,
    this.height,
    this.width,
    this.showHandlers = true,
  });

  @override
  _TransformableFrameState createState() => _TransformableFrameState();
}

class _TransformableFrameState extends State<TransformableFrame> {
  final double minWidth = 35;
  final double minHeight = 35;
  Matrix4 matrix = Matrix4.identity();
  GlobalKey key = GlobalKey();

  double centerPointX;
  double centerPointY;

  /// Translate data
  double startLocationX;
  double startLocationY;

  /// Scale data
  double width, height;

  set setWidth(double value) {
    width = value < minWidth ? minWidth : value;
  }

  set setHeight(double value) {
    height = value < minHeight ? minHeight : value;
  }

  @override
  void initState() {
    width = widget.width;
    height = widget.height;

    /// Initialize frame size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = key.currentContext.findRenderObject();

      centerPointX =
          renderBox.localToGlobal(Offset.zero).dx + renderBox.size.width / 2;
      centerPointY =
          renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height / 2;

      setWidth = renderBox.size.width;
      setHeight = renderBox.size.height;
    });

    super.initState();
  }

  void _onTranslateStartHandler(dragDetails) {
    startLocationX = dragDetails.globalPosition.dx;
    startLocationY = dragDetails.globalPosition.dy;
  }

  void _onRotateHandler(dragUpdateDetails) {
    setState(() {
      double endLocationX = dragUpdateDetails.globalPosition.dx;
      double endLocationY = dragUpdateDetails.globalPosition.dy;

      double m1 = startLocationY - centerPointY == 0
          ? 0
          : (startLocationX - centerPointX) / (startLocationY - centerPointY);
      double m2 = endLocationY - centerPointY == 0
          ? 0
          : (endLocationX - centerPointX) / (endLocationY - centerPointY);

      double angle = (m1 - m2) / (1 + m1 * m2);

      matrix = matrix..rotateZ(angle);
      startLocationX = endLocationX;
      startLocationY = endLocationY;
    });
  }

  void _onTranslateHandler(DragUpdateDetails dragUpdateDetails) {
    setState(() {
      double endLocationX = dragUpdateDetails.delta.dx;
      double endLocationY = dragUpdateDetails.delta.dy;
      centerPointX += endLocationX;
      centerPointY += endLocationY;

      matrix = matrix..translate(endLocationX, endLocationY);
    });
  }

  void _onResizeHandler(dragUpdateDetails) {
    double endLocationX = dragUpdateDetails.globalPosition.dx;
    double endLocationY = dragUpdateDetails.globalPosition.dy;

    setState(() {
      setWidth = width + (endLocationX - startLocationX);
      setHeight = height + (endLocationY - startLocationY);

      startLocationX = endLocationX;
      startLocationY = endLocationY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: matrix,
      alignment: FractionalOffset.center,
      child: Container(
        key: key,
        height: height,
        width: width,
        child: Stack(
          children: [
            Container(
              child: widget.child,
              margin: EdgeInsets.all(5),
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onPanStart: _onTranslateStartHandler,
                    onPanUpdate: _onRotateHandler,
                    child: _Handler(Icons.rotate_right),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onPanStart: _onTranslateStartHandler,
                    onPanUpdate: _onTranslateHandler,
                    child: _Handler(Icons.open_with),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onPanStart: _onTranslateStartHandler,
                    onPanUpdate: _onResizeHandler,
                    child: _Handler(Icons.zoom_out_map),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () =>
                        widget.onCloseTap == null ? null : widget.onCloseTap,
                    child: _Handler(Icons.close),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Handler extends StatelessWidget {
  final IconData icon;

  _Handler(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, size: 14),
    );
  }
}
