library transformable_frame;

import 'package:flutter/material.dart';

class TransformableFrame extends StatefulWidget {
  final Widget child;
  final Function onClose;
  final Function(Size) onResize;
  final Function(Matrix4) onTransform;
  final double height;
  final double width;
  final bool visable;

  TransformableFrame({
    @required this.child,
    this.height,
    this.width,
    this.visable = true,
    this.onClose,
    this.onResize,
    this.onTransform,
  });

  @override
  _TransformableFrameState createState() => _TransformableFrameState();
}

class _TransformableFrameState extends State<TransformableFrame> {
  final Size minSize = Size(35, 35);
  bool _visable;

  Matrix4 matrix = Matrix4.identity();
  GlobalKey key = GlobalKey();

  Offset centerPint;

  /// Translate data
  Offset startPoint;

  /// Resize data
  Size size;

  set setSize(Size value) {
    size = Size(
      value.width < minSize.width ? minSize.width : value.width,
      value.height < minSize.height ? minSize.height : value.height,
    );
  }

  @override
  void initState() {
    _visable = widget.visable;
    size = Size(widget.width, widget.height);

    /// Initialize frame size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = key.currentContext.findRenderObject();

      centerPint = Offset(
        renderBox.localToGlobal(Offset.zero).dx + renderBox.size.width / 2,
        renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height / 2,
      );

      setSize = renderBox.size;
    });

    super.initState();
  }

  void _onRotateHandler(dragUpdateDetails) {
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
      widget.onTransform(matrix);
    }
  }

  void _onTranslateStartHandler(dragDetails) {
    startPoint = dragDetails.globalPosition;
  }

  void _onTranslateHandler(DragUpdateDetails dragUpdateDetails) {
    setState(() {
      double endLocationX = dragUpdateDetails.delta.dx;
      double endLocationY = dragUpdateDetails.delta.dy;
      centerPint += dragUpdateDetails.delta;

      matrix = matrix..translate(endLocationX, endLocationY);
      _visable = false;
    });

    if (widget.onTransform != null) {
      widget.onTransform(matrix);
    }
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
      widget.onResize(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: matrix,
      alignment: FractionalOffset.center,
      child: GestureDetector(
        onPanStart: _onTranslateStartHandler,
        onPanUpdate: _onTranslateHandler,
        onPanEnd: (_) =>
            setState(() => _visable = !widget.visable ? false : true),
        child: Container(
          key: key,
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
                  border: _visable ? Border.all(color: Colors.black12) : null,
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
                        child: _Handler(Icons.rotate_right),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onPanStart: _onTranslateStartHandler,
                        onPanUpdate: _onResizeHandler,
                        child: Transform.rotate(
                          angle: 40,
                          child: _Handler(Icons.zoom_out_map),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: _Handler(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
