library transformable_frame;

import 'package:flutter/material.dart';

class TransformableFrame extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;

  TransformableFrame({
    @required this.child,
    this.height,
    this.width,
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

      setWidth = renderBox.size.width;
      setHeight = renderBox.size.height;
    });

    super.initState();
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
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(child: widget.child),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onPanStart: (dragDetails) {
                      RenderBox renderBox =
                          key.currentContext.findRenderObject();

                      centerPointX = renderBox.localToGlobal(Offset.zero).dx +
                          renderBox.size.width / 2;
                      centerPointY = renderBox.localToGlobal(Offset.zero).dy +
                          renderBox.size.height / 2;

                      startLocationX = dragDetails.globalPosition.dx;
                      startLocationY = dragDetails.globalPosition.dy;
                    },
                    onPanUpdate: (dragUpdateDetails) {
                      setState(() {
                        double endLocationX =
                            dragUpdateDetails.globalPosition.dx;
                        double endLocationY =
                            dragUpdateDetails.globalPosition.dy;

                        double m1 = (startLocationX - centerPointX) /
                            (startLocationY - centerPointY);
                        double m2 = (endLocationX - centerPointX) /
                            (endLocationY - centerPointY);

                        double angle = (m1 - m2) / (1 + m1 * m2);

                        matrix = matrix..rotateZ(angle);
                        startLocationX = endLocationX;
                        startLocationY = endLocationY;
                      });
                    },
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.rotate_right,
                        size: 14,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onPanStart: (dragStartDetails) {
                      startLocationX = dragStartDetails.globalPosition.dx;
                      startLocationY = dragStartDetails.globalPosition.dy;
                    },
                    onPanUpdate: (dragUpdateDetails) {
                      setState(() {
                        double endLocationX = dragUpdateDetails.delta.dx;
                        double endLocationY = dragUpdateDetails.delta.dy;

                        // centerPointX += endLocationX - startLocationX;
                        // centerPointY += endLocationY - startLocationY;

                        matrix = matrix..translate(endLocationX, endLocationY);
                      });
                    },
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.open_with,
                        size: 14,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onPanStart: (dragStartDetails) {
                      startLocationX = dragStartDetails.globalPosition.dx;
                      startLocationY = dragStartDetails.globalPosition.dy;
                    },
                    onPanUpdate: (dragUpdateDetails) {
                      double endLocationX = dragUpdateDetails.globalPosition.dx;
                      double endLocationY = dragUpdateDetails.globalPosition.dy;

                      setState(() {
                        setWidth = width + (endLocationX - startLocationX);
                        setHeight = height + (endLocationY - startLocationY);

                        startLocationX = endLocationX;
                        startLocationY = endLocationY;
                      });
                    },
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.zoom_out_map,
                        size: 14,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                      ),
                    ),
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
