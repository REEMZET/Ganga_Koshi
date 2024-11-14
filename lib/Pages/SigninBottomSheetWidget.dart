import 'dart:async';
import 'dart:convert'; // Import this for JSON encoding and decoding
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests

import '../Model/UserModel.dart';
import '../Utils/AppColors.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Login to Ganga Kosi'),
      ),
      body: SizedBox(),
    );
  }
}

class SignInBottomSheet extends StatefulWidget {
  final VoidCallback onSuccessLogin; // Function argument

  SignInBottomSheet({required this.onSuccessLogin}); // Constructor

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  bool otpSent = false;
  late String _phoneNumber = "";
  late String _otp;
  late String buttontext = 'ओटीपी प्राप्त करें'; // Button text
  late String _name;

  @override
  void initState() {
    super.initState();
  }

  // Function to send OTP
  Future<void> sendOtp() async {
    final url = Uri.parse("https://us-central1-instant-text-413611.cloudfunctions.net/Send_Otp");

    if (_phoneNumber.isEmpty) {
      print("Please enter a phone number.");
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phoneNumber": _phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          otpSent = true;
        });
        print("OTP sent successfully: ${data['message']}");
      } else {
        print("Failed to send OTP: ${response.body}");
      }
    } catch (error) {
      print("Error sending OTP: $error");
    }
  }

  // Function to verify OTP and authenticate with Firebase
  Future<void> verifyOtpAndAuthenticate() async {
    final url = Uri.parse("https://us-central1-instant-text-413611.cloudfunctions.net/verifyOtpAndAuthenticate");

    if (_phoneNumber.isEmpty || _otp.isEmpty) {
      print("Please enter both phone number and OTP.");
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phoneNumber": _phoneNumber, "otp": _otp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final firebaseToken = data['firebaseToken'];

        // Sign in with the custom Firebase token
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        print("User authenticated successfully.");
        User? user = FirebaseAuth.instance.currentUser;
        print("uid of user is ${user?.uid}");
        _pushUserModelToRealtimeDB();
        widget.onSuccessLogin();
        Navigator.pop(context);
      } else {
        print("Error verifying OTP: ${response.body}");
      }
    } catch (error) {
      print("Error verifying OTP: $error");
    }
  }

  void _pushUserModelToRealtimeDB() async {
    String phoneNumber = _phoneNumber.substring(3, 13);
    String externalId = phoneNumber;
    OneSignal.login(externalId);
    OneSignal.User.pushSubscription.optIn();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('GangaKoshi').child('User').child(user.uid);
        UserModel userModel = UserModel(
          name: _name,
          userPhone: phoneNumber,
          uid: user.uid,
          deviceId: kIsWeb ? 'web' : 'app',
          regDate: DateFormat('d/M/yy').format(DateTime.now()),
        );

        Map<String, dynamic> userMap = userModel.toMap();
        await usersRef.update(userMap);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created')));
      } catch (e) {
        print('Error adding user data to Realtime Database: $e'); // Log the error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding user data to Realtime Database: $e')));
      }
    } else {
      print('User is not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/logo.png', height: 80),
              ),
              SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextFormField(
                          onChanged: (value) {
                            _name = value;
                          },
                          maxLength: 25,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'अपना नाम दर्ज करें',
                            labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextFormField(
                          onChanged: (value) {
                            _phoneNumber = '+91' + value;
                          },
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'अपना फ़ोन नंबर दर्ज करें',
                            labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (otpSent) // Only show OTP text field when OTP is sent
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'ओटीपी दर्ज करें',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _otp = value;
                          },
                          maxLength: 4,
                        ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (buttontext == 'ओटीपी प्राप्त करें') {
                                if (_phoneNumber.length == 13) {
                                  setState(() {
                                    buttontext = 'ओटीपी भेजा जा रहा है';
                                  });
                                  try {
                                    await sendOtp();
                                    setState(() {
                                      buttontext = 'ओटीपी सत्यापित करें';
                                      otpSent = true; // Set OTP sent state
                                    });
                                  } catch (e) {
                                    print('ओटीपी भेजने में त्रुटि: $e');
                                    setState(() {
                                      buttontext = 'ओटीपी प्राप्त करें';
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('अवैध फोन नंबर')),
                                  );
                                }
                              } else {
                                if (_otp.length == 4) {
                                  setState(() {
                                    buttontext = 'ओटीपी सत्यापित हो रही है';
                                  });
                                  try {
                                    await verifyOtpAndAuthenticate();
                                    setState(() {
                                      buttontext = 'ओटीपी सत्यापित हो गई';
                                    });
                                  } catch (e) {
                                    print('ओटीपी सत्यापित करने में त्रुटि: $e');
                                    setState(() {
                                      buttontext = 'ओटीपी सत्यापित करें';
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('अवैध ओटीपी')),
                                  );
                                }
                              }
                            },
                            child: buttontext == 'ओटीपी भेजा जा रहा है' || buttontext == 'ओटीपी सत्यापित हो रही है'
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(buttontext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
