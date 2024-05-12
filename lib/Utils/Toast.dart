import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastWidget {
  static void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // Duration for which the toast will be visible
      gravity: ToastGravity.BOTTOM, // Toast position on the screen
      timeInSecForIosWeb: 3, // Time duration for iOS and web platforms
      backgroundColor: Colors.black54, // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }
}
