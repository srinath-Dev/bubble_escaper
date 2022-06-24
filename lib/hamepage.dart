import 'dart:async';

import 'package:bubble_escaper/ball.dart';
import 'package:bubble_escaper/button.dart';
import 'package:bubble_escaper/missile.dart';
import 'package:bubble_escaper/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction { LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  static double playerX = 0;
  double missileX = playerX;
  double missileHeight = 10;
  bool midShot = false;

  double ballX = 0.5;
  double ballY = 1;
  double velocity = 90;

  var ballDirection = direction.LEFT;

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
      } else {
        playerX -= 0.1;
      }
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 > 1) {
      } else {
        playerX += 0.1;
      }
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void startGame() {
    double time = 0;
    double height = 0;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      height = -5 * time * time + velocity * time;

      if (height < 0) {
        time = 0;
      }

      setState(() {
        ballY = heightToCoordinate(height);
      });

      if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
      } else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }

      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      if (playerDies()) {
        timer.cancel();
        _showDialog();
      }

      time += 0.1;
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[700],
            title: Center(
                child: Text(
              "Avolodan da 😂, play again!",
              style: TextStyle(color: Colors.white),
            )),
          );
        }); // AlertDialog
  }

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[700],
            title: Center(
                child: Text(
              "Winner 😎",
              style: TextStyle(color: Colors.white),
            )),
          );
        }); // AlertDialog
  }

  void fireMissile() {
    if (midShot == false) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        midShot = true;

        setState(() {
          missileHeight += 10;
        });

        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        if (ballY > heightToCoordinate(missileHeight) &&
            (ballX - missileX).abs() < 0.03) {
          resetMissile();
          ballX = 5;
          timer.cancel();
          _showSuccessDialog();
        }
      });
    }
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 10;
    midShot = false;
  }

  bool playerDies() {
    if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
      return true;
    } else {
      return false;
    }
  }

  double heightToCoordinate(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double position = 1 - 2 * height / totalHeight;
    return position;
  }

  void retry() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // Material page route makes it
        // slide from the bottom to the top
        //
        // If you want it to slide from the right to the left, use
        // `CupertinoPageRoute()` from the cupertino library.
        //
        // If you want something else, then create your own route
        // https://flutter.dev/docs/cookbook/animation/page-route-animation
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }

        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/bgspace.jpg"),
                        fit: BoxFit.cover)),
                // color: Colors.green[300],
                child: Center(
                    child: Stack(children: [
                  MyBall(ballX: ballX, ballY: ballY),
                  MyMissile(
                    missileHeight: missileHeight,
                    missileX: missileX,
                  ),
                  MyPlayer(playerX: playerX),
                ]))),
          ),
          Expanded(
              child: Container(
            color: Colors.green[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button(
                      icon: Icons.keyboard_double_arrow_left_rounded,
                      function: moveLeft,
                    ),
                    Button(
                      icon: Icons.rocket_launch,
                      function: fireMissile,
                    ),
                    Button(
                      icon: Icons.keyboard_double_arrow_right_rounded,
                      function: moveRight,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Button(
                    icon: Icons.play_arrow,
                    function: startGame,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Button(
                    icon: Icons.replay,
                    function: retry,
                  ),
                ]),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
