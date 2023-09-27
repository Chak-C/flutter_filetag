import 'package:flutter/material.dart';
import 'package:foldtag/namer.dart';
import 'package:provider/provider.dart';
import '../main.dart';

// Usage: tick_page, custom_page
class CBFactory extends StatelessWidget {
  const CBFactory({
    super.key,
    required this.item,
    required this.description,
    required this.displaySynonym,
    this.synonym = const [],
  });

  final AttributeObject item;
  final String description;
  final bool displaySynonym;
  final List<String> synonym;
  
  @override
  Widget build(BuildContext context) {
    if(!displaySynonym) {
      return CBNoAnimate(item: item, description: description);
    } else {
      if(synonym.isNotEmpty) {
        return CBAnimate(item: item, description: description, synonym: synonym);
      }
      return CBNoAnimate(item: item, description: description);
    }
  }
}

/// Checkbox without rotating animation of synonyms
/// 
/// For with animation, check CBAnimate class
class CBNoAnimate extends StatefulWidget {
  const CBNoAnimate({
    super.key, 
    required this.item, 
    required this.description
  });

  final AttributeObject item;
  final String description;

  @override
  State<CBNoAnimate> createState() => _CBNoAnimateState();
}

class _CBNoAnimateState extends State<CBNoAnimate> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    bool isChecked = appState.included.contains(widget.item);

    return CheckboxListTile(
      title: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: Text(widget.item.attribute),
      ), 
      subtitle: Text(widget.description),
      value: isChecked,
      onChanged: (value) {
        appState.toggleIncluded(widget.item);
        setState(() => isChecked = value!);
      }, 
    );
  }
}

/// Checkbox with rotating animation of synonyms
/// 
/// For without animation, check CBNoAnimate class
class CBAnimate extends StatefulWidget {
  const CBAnimate({
    super.key, 
    required this.item, 
    required this.description,
    required this.synonym,
  });

  final AttributeObject item;
  final String description;
  final List<String> synonym;

  @override
  State<CBAnimate> createState() => _CBAnimateState();
}

class _CBAnimateState extends State<CBAnimate> 
  with TickerProviderStateMixin {
  late AnimationController _controller;
  
  var synonymIndex = 0;

  @override
  void initState() {
      super.initState();

      _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );

      _controller.addStatusListener((status) {
        if(status == AnimationStatus.completed) {
          setState(() {
            synonymIndex = (synonymIndex + 1) % (widget.synonym.length + 1);
          });
          
          // reset and start animation again
          _controller.reset();
          _controller.forward();
        }
      });

      //starts animation upon built
      _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    bool isChecked = appState.included.contains(widget.item);

    var cycleList = [widget.item.attribute] + widget.synonym;

    return CheckboxListTile(
      title: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: Text(
          cycleList[synonymIndex],
          key: ValueKey<String>(cycleList[synonymIndex]),
        ),
          //: Text(widget.item),
      ), 
      subtitle: Text(widget.description),
      value: isChecked,
      onChanged: (value) {
        appState.toggleIncluded(widget.item);
        setState(() => isChecked = value!);
      }, 
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}