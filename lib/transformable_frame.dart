library transformable_frame;

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

class TransformableFrame extends StatefulWidget {
  final Widget child;
  final bool visable;
  final Size? size;
  final Matrix4? matrix;
  final Function()? onTap;
  final Function()? onClose;
  final Function(Size)? onResize;
  final Function(Matrix4)? onTransform;

  TransformableFrame({
    required this.child,
    this.size,
    this.onTap,
    this.matrix,
    this.onClose,
    this.onResize,
    this.onTransform,
    this.visable = true,
  });

  @override
  _TransformableFrameState createState() => _TransformableFrameState();
}

class _TransformableFrameState extends State<TransformableFrame> {
  final Size minSize = Size(35, 35);
  late bool _visable;

  late Matrix4 matrix;
  late Matrix4Transform _matrix4transform;
  late Matrix4Transform _handlerMatrix4transform;
  late Matrix4 _handlerMatrix;

  GlobalKey key = GlobalKey();

  late Offset centerPint = Offset(0, 0);

  /// Translate data
  late Offset startPoint;

  /// Resize data
  late Size size;

  set setSize(Size value) {
    size = Size(
      value.width < minSize.width ? minSize.width : value.width,
      value.height < minSize.height ? minSize.height : value.height,
    );
  }

  @override
  void initState() {
    matrix = widget.matrix ?? Matrix4.identity();
    _handlerMatrix = Matrix4.identity();
    size = widget.size ?? Size(double.infinity, double.infinity);

    super.initState();
  }

  void _onRotateHandler(DragUpdateDetails dragUpdateDetails) {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    centerPint = Offset(
      renderBox.localToGlobal(Offset.zero).dx,
      renderBox.localToGlobal(Offset.zero).dy,
    );

    setState(() {
      Offset endPoint = dragUpdateDetails.globalPosition;

      double m1 = startPoint.dy - centerPint.dy == 0
          ? 0
          : (startPoint.dx - centerPint.dx) / (startPoint.dy - centerPint.dy);
      double m2 = endPoint.dy - centerPint.dy == 0
          ? 0
          : (endPoint.dx - centerPint.dx) / (endPoint.dy - centerPint.dy);

      double angle = (m1 - m2) / (1 + m1 * m2);

      matrix = matrix..rotateZ(angle);
      startPoint = endPoint;
    });

    if (widget.onTransform != null) {
      widget.onTransform!(matrix);
    }
  }

  void _onTranslateStartHandler(dragDetails) {
    startPoint = dragDetails.globalPosition;
  }

  void _onResizeHandler(dragUpdateDetails) {
    Offset endLocation = dragUpdateDetails.globalPosition;

    setState(() {
      setSize = Size(
        size.width + (endLocation.dx - startPoint.dx),
        size.height + (endLocation.dy - startPoint.dy),
      );

      startPoint = endLocation;
    });

    if (widget.onResize != null) {
      widget.onResize!(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    _visable = widget.visable;

    return Transform(
      transform: matrix,
      alignment: FractionalOffset.center,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          _matrix4transform = Matrix4Transform.from(matrix);
          _handlerMatrix4transform = Matrix4Transform.from(_handlerMatrix);

          startPoint = scaleStartDetails.focalPoint;
        },
        onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
          setState(() {
            _handlerMatrix = _handlerMatrix4transform
                .scale(1 / scaleUpdateDetails.scale)
                .matrix4;

            _visable = false;
            matrix = _matrix4transform
                .rotate(scaleUpdateDetails.rotation)
                // .scale(scaleUpdateDetails.scale)
                .translate(
                  x: scaleUpdateDetails.focalPoint.dx - startPoint.dx,
                  y: scaleUpdateDetails.focalPoint.dy - startPoint.dy,
                )
                .matrix4;
          });

          if (widget.onTransform != null) {
            widget.onTransform!(matrix);
          }
        },
        onScaleEnd: (ScaleEndDetails onPanEnd) {
          if (widget.onTransform != null) {
            widget.onTransform!(matrix);
          }

          setState(() => _visable = !widget.visable ? false : true);
        },
        child: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Container(
                child: widget.child,
                margin: EdgeInsets.all(5),
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  border:
                      widget.visable ? Border.all(color: Colors.grey) : null,
                ),
              ),
              Visibility(
                visible: _visable,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        onPanStart: _onTranslateStartHandler,
                        onPanUpdate: _onRotateHandler,
                        child: _buildHandler(Icons.rotate_right),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onPanStart: _onTranslateStartHandler,
                        onPanUpdate: _onResizeHandler,
                        child: _buildHandler(Icons.zoom_out_map),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: _buildHandler(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
              // Find center point from this widget
              Center(
                child: Container(
                  key: key,
                  width: 1,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandler(IconData iconData) {
    final scaleX = matrix.getColumn(0).length;
    final scaleY = matrix.getColumn(1).length;
    final scaleZ = matrix.getColumn(2).length;
    return Transform(
        transform: Matrix4.identity()
          ..scale(1 / scaleX, 1 / scaleY, 1 / scaleZ),
        child: _Handler(iconData));
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
