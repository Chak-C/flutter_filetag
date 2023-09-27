import 'dart:async';

import 'package:flutter/material.dart';

/// This file contains widgets that are customized for certain pages and events.
/// The following widgets are deemed too complex/unfit/widely used to be integrated with their corresponding
/// classes and files thus are placed here.'
/// 
/// Expectations: Simplify their logic and integrate them back to their belonging sections.

/// Flashing sized box:
/// 
/// Usage: Selection page -> Dropdown menu widget
/// Event: Appears when user presses continue button without valid dropdown selection(s).
class FlashingBox extends StatefulWidget {
  const FlashingBox({Key? key, required this.width}) : super(key : key);
  
  final double? width;

  @override
  State<FlashingBox> createState() => FlashingBoxState();
}

class FlashingBoxState extends State<FlashingBox> {
  late bool _isRed;
  late Timer _timer;
  int _remainingTime = 4000; //time in miliseconds

  @override
  void initState() {
    super.initState();
    _isRed = false;
    _startFlashing();
  }

  void _startFlashing() {
    Duration duration = const Duration(milliseconds: 500);
    _timer = Timer.periodic(duration, (timer) {

      setState(() {
        if(_remainingTime > 0) {
          if(mounted) { 
            _isRed = !_isRed;
            _remainingTime -= 500; 
            }
        } else {
          // reset state
          if(mounted) { _isRed = false; }
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: widget.width,
          child: AnimatedContainer(
            duration: const Duration (milliseconds: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isRed ? Colors.red.withOpacity(0.7) : Colors.transparent,
              ),
          )
        );
      }
    );
  }
}

/// Default title + description style used throughout application
/// Usage: tick_page, add_page, custom_page
class DefaultTitle extends StatelessWidget {
  final dynamic title;
  final dynamic description;

  const DefaultTitle({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: '$title\n',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          TextSpan(
            text: description.toString(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}