import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Model/UserModel.dart';
import '../Utils/AppColors.dart';
import 'HomePage.dart';
import 'MyBooking.dart';
import 'Pagerouter.dart';
import 'SigninBottomSheetWidget.dart';
import 'TestRequest.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? phoneNumber;
  bool isLoading = true;
  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;
  UserModel? userModel;

  @override
  void initState() {
    if (user != null) {
      phoneNumber = user!.phoneNumber.toString().substring(3, 13);
      getUserDetails(phoneNumber.toString());
    }
    super.initState();
  }

  Future<void> getUserDetails(String userPhoneNumber) async {

    userRef = FirebaseDatabase.instance.reference().child('GangaKoshi/User/${user!.uid}');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = UserModel(
          name: data['name'] ?? '',
          userPhone: data['userphone'] ?? '',
          uid: data['uid'] ?? '',
          regDate: data['regdate'] ?? '', deviceId: '',
        );
      }
      isLoading = false; // Data is loaded
      setState(() {}); // Trigger a UI update
    });
  }

  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, customPageRoute(SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(title: Text('Profile'),elevation: 3,),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                color: AppColors.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20,top: 10),
                      child: Container(
                        padding: EdgeInsets.all(8), // Border width
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2.0), // Adjust width as needed
                        ),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(65), // Image radius
                            child: Image.asset('assets/images/farmer.png', fit: BoxFit.cover),
                          ),
                        ),
                      )

                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Name- ${userModel!.name}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              customPageRoute( MyBooking()
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Set the background color
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.list_alt,color: Colors.white,),
                            Text('My Booking',style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              customPageRoute( TestRequest()
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Set the background color
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.science_rounded,color: Colors.white,),
                            Text('Test Report',style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Profile Details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.phone_android_outlined, color: Colors.green),
                  title: Text('+91 ${userModel!.userPhone}'),
                  onTap: () {
                    // Call a function when the user taps
                  },
                ),
                Divider(),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.history, color: Colors.green),
                  title: Text('Test Report'),
                  onTap: () {
                    /* Navigator.push(
                        context,
                        customPageRoute( AboutPage()
                        ));*/
                  },
                ),
                Divider(),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.info, color: Colors.green),
                  title: Text('About Us'),
                  onTap: () {
                   /* Navigator.push(
                        context,
                        customPageRoute( AboutPage()
                        ));*/
                  },
                ),
                Divider(),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.info, color: Colors.green),
                  title: Text('Privacy_policy'),
                  onTap: () {

                  },
                ),
                Divider(),
                ListTile(/*  Navigator.push(
                        context,
                        customPageRoute( PrivacyPolicyPage()
                        ));*/
                  dense: true,
                  leading: Icon(Icons.description, color: Colors.green),
                  title: Text('Terms and Conditions'),
                  onTap: () {
                    /*Navigator.push(
                        context,
                        customPageRoute( TermsAndConditionsPage()
                        ));*/
                  },
                ),
                Divider(),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.logout, color: Colors.green),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    setState(() {
                      user=FirebaseAuth.instance.currentUser;
                      Navigator.push(
                          context,
                          customPageRoute( HomePage()
                          ));
                    });
                  },
                ),
                Divider(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
