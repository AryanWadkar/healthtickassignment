import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:healthtickassignment/components/buttons.dart';
import 'package:healthtickassignment/config/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  double currStage = 0;
  int totalStages = 3;
  bool initTimer = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBgColor,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: kPrimaryBgColor,
        shadowColor: Colors.white.withOpacity(0.8),
        elevation: 0.5,
        title: const Text(
          'Mindful Meal Timer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DotsIndicator(
              dotsCount: totalStages,
              position: currStage,
              decorator: const DotsDecorator(
                  color: Color(0xff62606c), // Inactive color
                  activeColor: Colors.white,
                  activeSize: Size(15, 15),
                  size: Size(10, 10)),
            ),
            Expanded(
              flex: 8,
              child: PageView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: (newPage) {
                  setState(() {
                    currStage = newPage.toDouble();
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  IndividualTimer(
                    heading: 'Nom Nom :)',
                    subtxt:
                        'You have 10 minutes to eat before the pause.Focus on eating slowly',
                    countDownFrom: 30,
                    onTimerFin: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                    },
                    showFull: false,
                  ),
                  IndividualTimer(
                    heading: 'Break Time',
                    subtxt:
                        'Take a five minute break to check your level of fullness',
                    countDownFrom: 30,
                    onTimerFin: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                    },
                    showFull: true,
                  ),
                  IndividualTimer(
                      heading: 'Finish Your Meal',
                      subtxt: 'You can eat until you feel full',
                      countDownFrom: 30,
                      showFull: true,
                      onTimerFin: () {
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: const Text("You did it!!"),
                                  content: const Text(
                                      "Congratulations you just had a mindful meal!!\n Hopefully that makes you want to hire Aryan :)"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                            ..pop()
                                            ..pop();
                                        },
                                        child: const Text("Yay"))
                                  ],
                                ));
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndividualTimer extends StatefulWidget {
  const IndividualTimer(
      {Key? key,
      required this.heading,
      required this.subtxt,
      required this.countDownFrom,
      required this.onTimerFin,
      required this.showFull})
      : super(key: key);
  final String heading;
  final String subtxt;
  final int countDownFrom;
  final Function onTimerFin;
  final bool showFull;
  @override
  State<IndividualTimer> createState() => _IndividualTimerState();
}

class _IndividualTimerState extends State<IndividualTimer> {
  String actionButtonLabel = "START";
  bool soundOn = true;
  String prev = "0";
  bool startedRun = false;
  final CountDownController _controller = CountDownController();
  final player = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  final GlobalKey<_CountDownTimerState> _childWidgetKey =
      GlobalKey<_CountDownTimerState>();

  void _handleStartAnimation() {
    _childWidgetKey.currentState?.startAnimation();
  }

  void _handleStopAnimation() {
    _childWidgetKey.currentState?.stopAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.heading,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            widget.subtxt,
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: CountDownTimer(
              key: _childWidgetKey,
              seconds: widget.countDownFrom,
              onChange: (val) {
                String sec = val.split(":")[1];
                if (sec != prev) {
                  prev = sec;
                  if (widget.countDownFrom - int.parse(sec) > 25 &&
                      startedRun &&
                      soundOn) {
                    player.play(AssetSource('sounds/countdown_tick.mp3'));
                  }
                }
              },
              onComplete: () {
                widget.onTimerFin();
              },
              onStart: () {
                setState(() {
                  actionButtonLabel = "PAUSE";
                  startedRun = true;
                });
              },
            ),
          ),
          Switch(
              value: soundOn,
              onChanged: (newSoundState) {
                setState(() {
                  soundOn = newSoundState;
                });
              }),
          Text(
            soundOn ? 'Sound On' : 'Sound Off',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          GreenFilledButton(
              onPress: () {
                if (actionButtonLabel == "START") {
                  _controller.start();
                  _handleStartAnimation();
                } else if (actionButtonLabel == "PAUSE") {
                  _controller.pause();
                  _handleStopAnimation();
                  setState(() {
                    actionButtonLabel = "RESUME";
                  });
                } else if (actionButtonLabel == "RESUME") {
                  _controller.resume();
                  _handleStartAnimation();
                  setState(() {
                    actionButtonLabel = "PAUSE";
                  });
                }
              },
              label: actionButtonLabel),
          Visibility(
            visible: startedRun || widget.showFull,
            child: BorderedButton(
                onPress: () {
                  Navigator.pop(context);
                },
                label: 'LET\'S STOP NOW I\'M FULL'),
          )
        ],
      ),
    );
  }
}

/*
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: CircularCountDownTimer(
              duration: widget.countDownFrom,
              controller: _controller,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.45,
              ringColor: Colors.grey[300]!,
              fillColor: kBrandColorGreen,
              backgroundColor: Colors.white,
              strokeWidth: 20.0,
              textStyle: const TextStyle(
                  fontSize: 33.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.MM_SS,
              isReverse: true,
              isReverseAnimation: true,
              isTimerTextShown: true,
              autoStart: false,
              onStart: () {
                debugPrint('Countdown Started');
                setState(() {
                  actionButtonLabel = "PAUSE";
                  startedRun = true;
                });
              },
              onComplete: () {
                widget.onTimerFin();
              },
              onChange: (String timeStamp) {
                String sec = timeStamp.split(":")[1];
                if (sec != prev) {
                  prev = sec;
                  if (widget.countDownFrom - int.parse(sec) > 25 &&
                      startedRun &&
                      soundOn) {
                    player
                        .play(AssetSource('assets/sounds/countdown_tick.mp3'));
                  }
                }
              },
            ),
          ),
*/

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
