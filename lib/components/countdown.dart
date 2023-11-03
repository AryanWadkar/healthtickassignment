import 'package:flutter/material.dart';
import 'dart:math';

import 'package:healthtickassignment/config/constants.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer(
      {super.key,
      required this.seconds,
      this.onChange,
      this.onComplete,
      this.onStart});
  final int seconds;
  final Function()? onComplete;
  final Function(String)? onChange;
  final Function()? onStart;
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      } else if (status == AnimationStatus.reverse) {
        if (widget.onStart != null) {
          widget.onStart!();
        }
      }
    });

    controller.addListener(() {
      if (widget.onChange != null) {
        widget.onChange!(timerString);
      }
    });
  }

  void startAnimation() {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
  }

  void stopAnimation() {
    controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, w) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                        painter: CustomTimerPainter(
                      animation: controller,
                      backgroundColor: Colors.white,
                      color: kBrandColorGreen,
                    )),
                  ),
                  Align(
                    alignment: FractionalOffset.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          timerString,
                          style:
                              TextStyle(fontSize: 112.0, color: Colors.black),
                        ),
                        const Text(
                          "Minutes remaining",
                          style: TextStyle(fontSize: 20.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // FloatingActionButton.extended(
            //     onPressed: () {
            //       if (controller.isAnimating) {
            //         controller.stop();
            //       } else {
            //         controller.reverse(
            //             from: controller.value == 0.0 ? 1.0 : controller.value);
            //       }
            //     },
            //     icon: Icon(
            //         controller.isAnimating ? Icons.pause : Icons.play_arrow),
            //     label: Text(controller.isAnimating ? "Pause" : "Play")),
          ],
        );
      },
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);
    final backgroundCircleRadius = min(centerX, centerY);
    final arcRadius = backgroundCircleRadius - 10;
    final dashedCircleRadius = backgroundCircleRadius - 30;

    final sweepAngle = 2 * pi * animation.value;
    const startAngle = -pi / 2;

    final backgroundCirclePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, backgroundCircleRadius, backgroundCirclePaint);

    final dashedCirclePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < 60; i++) {
      final angle = ((i / 60) * 2 * pi) - pi / 2;
      final startX = centerX + cos(angle) * dashedCircleRadius;
      final startY = centerY + sin(angle) * dashedCircleRadius;
      final endX = centerX + cos(angle) * (dashedCircleRadius + 15);
      final endY = centerY + sin(angle) * (dashedCircleRadius + 15);
      final line = Offset(startX, startY);
      final lineEnd = Offset(endX, endY);
      if (angle >= startAngle && angle <= (sweepAngle + (-pi / 2))) {
        canvas.drawLine(line, lineEnd, dashedCirclePaint);
      }
    }

    final dashedCirclePaintX = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < 60; i++) {
      final angle = ((i / 60) * 2 * pi) - pi / 2;
      final startX = centerX + cos(angle) * dashedCircleRadius;
      final startY = centerY + sin(angle) * dashedCircleRadius;
      final endX = centerX + cos(angle) * (dashedCircleRadius + 15);
      final endY = centerY + sin(angle) * (dashedCircleRadius + 15);
      final line = Offset(startX, startY);
      final lineEnd = Offset(endX, endY);
      if (!(angle >= startAngle && angle <= (sweepAngle + (-pi / 2)))) {
        canvas.drawLine(line, lineEnd, dashedCirclePaintX);
      }
    }

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 10.0;

    final arcStartAngle = startAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      arcStartAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
