import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int timeLeftPlayerOne = 60000;
  int timeLeftPlayerTwo = 60000;
  String playerTurn = 'player_one';
  bool start = false;
  late Timer time;

  static const double _kItemExtent = 32.0;
  static const List<int> timerList = <int>[
    1,
    2,
    3,
    5,
    10,
    30,
  ];
  final player = AudioPlayer();
  int _selectedTime = 0;

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216.h,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void changePlayerTurn(String player) {
    if (timeLeftPlayerOne > 0 && timeLeftPlayerTwo > 0) {
      if (start) {
        playerTurn = player;
        time.cancel();
      } else {
        start = true;
      }
      startCountDown();
    }
  }

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void startCountDown() {
    time = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeLeftPlayerOne > 0 && timeLeftPlayerTwo > 0) {
        if (playerTurn == 'player_one') {
          setState(() {
            timeLeftPlayerOne -= 100;
          });
        } else {
          setState(() {
            timeLeftPlayerTwo -= 100;
          });
        }
      } else {
        player.play(AssetSource('chess_cloak_time_up_notification.mp3'));
        timer.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      timeLeftPlayerOne =
          timeLeftPlayerTwo = timerList[_selectedTime] * 60 * (1000);
      playerTurn = 'player_one';
      start = false;
      time.cancel();
    });
  }

  void pauseTimer() {
    // ignore: unnecessary_null_comparison
    if (time != null) {
      setState(() {
        time.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPlayerTimer(playerTurn: 'player_one', turn: -2),
            Row(
              children: [
                buildButton(icon: Icons.restore, onPressed: resetTimer),
                buildButton(icon: Icons.pause, onPressed: pauseTimer),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showDialog(
                          CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: _kItemExtent,
                            scrollController: FixedExtentScrollController(
                              initialItem: _selectedTime,
                            ),
                            onSelectedItemChanged: (int selectedItem) {
                              setState(() {
                                _selectedTime = selectedItem;
                                timeLeftPlayerOne = timeLeftPlayerTwo =
                                    timerList[selectedItem] * 60 * (1000);
                              });
                            },
                            children: List<Widget>.generate(timerList.length,
                                (int index) {
                              return Center(
                                  child: Text("${timerList[index]} min"));
                            }),
                          ),
                        ),
                    child: const Icon(
                      Icons.timer,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    )),
              ],
            ),
            buildPlayerTimer(playerTurn: 'player_two', turn: 0),
          ],
        ),
      ),
    );
  }

  Widget buildPlayerTimer({required String playerTurn, required int turn}) {
    return CupertinoButton(
      disabledColor: Colors.black45,
      color: playerTurn == 'player_one'
          ? const Color.fromRGBO(100, 197, 26, 1)
          : const Color.fromRGBO(218, 208, 21, 1),
      minSize: 400,
      onPressed: this.playerTurn == playerTurn
          ? (this.playerTurn == 'player_one'
              ? () => changePlayerTurn('player_two')
              : () => changePlayerTurn('player_one'))
          : null,
      child: RotatedBox(
        quarterTurns: turn,
        child: Text(
          playerTurn == 'player_one'
              ? timeLeftPlayerOne == 0
                  ? 'Time Up'
                  : _printDuration(Duration(milliseconds: timeLeftPlayerOne))
              : timeLeftPlayerTwo == 0
                  ? 'Time Up'
                  : _printDuration(Duration(milliseconds: timeLeftPlayerTwo)),
          style: const TextStyle(fontSize: 60),
        ),
      ),
    );
  }

  Widget buildButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return CupertinoButton(
      color: const Color.fromARGB(255, 250, 250, 250),
      minSize: 20,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: const Color.fromRGBO(0, 0, 0, 1),
      ),
    );
  }
}
