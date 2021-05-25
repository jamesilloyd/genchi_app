import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {this.buttonColor,
      this.buttonTitle,
      @required this.onPressed,
      this.fontColor = Colors.white,
      this.style = const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18.0),
      this.elevation = true});

  final Color buttonColor;
  final String buttonTitle;
  final Function onPressed;
  final Color fontColor;
  final bool elevation;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        height: 42.0,
        minWidth: 200,
        color: buttonColor,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: Text(
          buttonTitle,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: style.copyWith(color: fontColor),
        ),
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
        enableFeedback: true,
        onHighlightChanged: (pressed) {
          if (pressed) {
            HapticFeedback.lightImpact();
          }
        },
        elevation: elevation ? 2 : 0,
        highlightElevation: elevation ? 5 : 0,
        // hoverElevation: 20,
      ),
    );
  }
}
