import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganga_kosi/Pages/HomePage.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:restart_app/restart_app.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool otpSent = false;
  late String _phoneNumber="";
  late String _verificationId;
  late String _otp;
  late String buttontext = 'ओटीपी प्राप्त करें';

  late String _name;


  @override
  void initState() {
    super.initState();

  }
  Future<void> _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('d/M/yy').format(currentDate);
      String  device;
      if (kIsWeb) {
        device='web';
      } else {
        device='app';

      }
      UserModel userModel = UserModel(
        name: _name,
        userPhone: _phoneNumber.substring(3,13),
        uid: user!.uid.toString(),
        deviceId: device,
        regDate: formattedDate,
      );
      _pushUserModelToRealtimeDB(userModel);
      widget.onSuccessLogin();
      Navigator.pop(context);

    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e')));
      print('Verification Failed: $e');
    };

    final PhoneCodeSent codeSent = (String verificationId, int? resendToken) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {};

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending verification code: $e')));
      print('Error sending verification code: $e');
    }
  }

  Future<void> verify() async {
    try {
      // Use _verificationId and the OTP entered by the user to create a PhoneAuthCredential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otp,
      );
      await _auth.signInWithCredential(credential);
      User? user = FirebaseAuth.instance.currentUser;
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('d/M/yy').format(currentDate);
      String  device;
      if (kIsWeb) {
        device='web';
      } else {
        device='app';

      }
      UserModel userModel = UserModel(
        name: _name,
        userPhone: _phoneNumber.substring(3,13),
        uid: user!.uid.toString(),
        deviceId: device,
        regDate: formattedDate,
      );

      _pushUserModelToRealtimeDB(userModel);
      widget.onSuccessLogin();
      Navigator.pop(context);


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying OTP: $e')));
      print('Error verifying OTP: $e');
    }
  }

  void _pushUserModelToRealtimeDB(UserModel userModel) async {
    String phoneNumber = _phoneNumber.substring(3, 13);
    var externalId = phoneNumber; // You will supply the external id to the OneSignal SDK
    OneSignal.login(externalId);
    OneSignal.User.pushSubscription.optIn();

    try {
      final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('GangaKoshi').child('User').child(phoneNumber);
      Map<String, dynamic> userMap = userModel.toMap();
      await usersRef.update(userMap);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('account created')));

   // Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding user data to Realtime Database: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {

    User? user = _auth.currentUser;

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
                child: Image.asset('assets/images/logo.png',height: 80,),
              ),
               SizedBox(height:4),
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
                         onChanged: (value){
                           _name=value;
                         },
                          maxLength: 25,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'अपना नाम दर्ज करें',
                            labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
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
                            _phoneNumber = '+91'+value;
                          },
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'अपना फ़ोन नंबर दर्ज करें',
                            labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
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
                          maxLength: 6,
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
                                    await _verifyPhoneNumber();
                                    await Future.delayed(Duration(seconds: 4));
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
                                if (_otp.length == 6) {
                                  setState(() {
                                    buttontext = 'ओटीपी सत्यापित हो रही है';
                                  });
                                  try {
                                    await verify();
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
                                ? CircularProgressIndicator() // Show progress indicator
                                : Text(buttontext,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Change the background color to green
                            ),
                          ),
                        ),
                      ),



                      const SizedBox(height: 8),

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
