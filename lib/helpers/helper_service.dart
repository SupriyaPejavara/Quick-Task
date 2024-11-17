import 'package:flutter/material.dart';

class HelperService {  
  void showMessage(BuildContext context, String message, {bool? error}) {
    const double height = 70;
    const EdgeInsets padding = EdgeInsets.fromLTRB(50, 0, 50, 0);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: Container(
        padding: padding,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: error != null && error ? Colors.red : Colors.green,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: padding,
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1000,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
