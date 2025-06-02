import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,

      home: const HomePage(),
    );
  }
}

enum CircleSide { left, right }

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;
    late bool clockwise;
    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        clockwise = true;
        offset = Offset(0, size.height);
        break;
    }
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );
    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide side;
  const HalfCircleClipper({required this.side});

  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationController;
  late Animation<double> _counterClockwiseRotationAnimation;
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _counterClockwiseRotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _counterClockwiseRotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2),
    ).animate(
      CurvedAnimation(
        parent: _counterClockwiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    _flipAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _flipAnimation=Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
        CurvedAnimation(parent:_flipAnimationController, curve: Curves.bounceOut)
    );

    _counterClockwiseRotationController.addStatusListener((status){
      if(status.isCompleted){
        _flipAnimation=Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value+pi,

        ).animate(
          CurvedAnimation(parent:_flipAnimationController, curve: Curves.bounceOut)
            );

        _flipAnimationController..reset()..forward();
      }
    });

    _flipAnimationController.addStatusListener((status){
      if(status.isCompleted){
        _counterClockwiseRotationAnimation = Tween<double>(
          begin: _counterClockwiseRotationAnimation.value,
          end: _counterClockwiseRotationAnimation.value + -(pi / 2),
        ).animate(
          CurvedAnimation(
            parent: _counterClockwiseRotationController,
            curve: Curves.bounceOut,
          ),
        );

        _counterClockwiseRotationController..reset()..forward();
      }
    });

  }

  @override
  void dispose() {
    _counterClockwiseRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 1),(){
        _counterClockwiseRotationController..reset()..forward();
        }
    );


    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _counterClockwiseRotationController,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..rotateZ(_counterClockwiseRotationAnimation.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _flipAnimationController,
                    builder:(context,child) {
                      return Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..rotateY(_flipAnimation.value),
                        child: ClipPath(
                          clipper: const HalfCircleClipper(
                              side: CircleSide.left),
                          child: Container(
                            width: 150,
                            height: 150,
                            color: Colors.blueAccent,
                          ),
                        ),
                      );
                    }
                  ),
                  AnimatedBuilder(
                    animation: _flipAnimationController,
                    builder:(context,child) {
                      return Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                        child: ClipPath(
                          clipper: const HalfCircleClipper(side: CircleSide
                              .right),
                          child: Container(
                            width: 150,
                            height: 150,
                            color: Colors.yellowAccent,
                          ),
                        ),
                      );
                    }
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
