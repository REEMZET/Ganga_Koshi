import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart' as picker;
import 'package:intl/intl.dart';

import '../../Model/UserModel.dart';
import '../SigninBottomSheetWidget.dart';
class CropScan extends StatefulWidget {
  const CropScan({super.key});

  @override
  State<CropScan> createState() => _CropScanState();
}
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
class _CropScanState extends State<CropScan> {
  File? _image;
  bool isupLoading = false;
  UserModel? userModel;



  Future<void> _pickImage(picker.ImageSource source) async {
    final imagePicker = picker.ImagePicker(); // Use alias for image_picker package
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }
  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('GangaKoshi/User/$phoneNumber');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
        userModel = UserModel(
          name: data['name'] ?? '',
          userPhone: data['userphone'] ?? '',
          uid: data['uid'] ?? '',
          regDate: data['regdate'] ?? '',
          deviceId: '',
        );
        setState(() {
          completer.complete();
        });
      }
    });
    return completer.future;
  }

  void submittestreport() async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      phoneNumber= user.phoneNumber.toString().substring(3, 13);
    }else{
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        elevation: 4,
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle:true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SignInBottomSheet(onSuccessLogin: (){
                    setState(() {
                      user=FirebaseAuth.instance.currentUser;
                      phoneNumber= user?.phoneNumber.toString().substring(3, 13);
                      getUserDetails();
                    });
                  },)
                ],
              ),
            ),
          );
        },
      );
      return;
    }
    if(_image==null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Choose Image'),
        ),
      );
      return ;
    }
    setState(() {
      isupLoading = true; // Set isLoading to true when submitting
    });

    final FirebaseStorage _storage = FirebaseStorage.instance;
    var uploadTask = _storage
        .ref()
        .child('Images/leaveimages/${DateTime.now().millisecondsSinceEpoch}.jpg')
        .putFile(_image!);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();



    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(now);

    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;


    DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi').child('Admin/testrequest');
    DatabaseReference _userdatabaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi/User/').child(phoneNumber!).child('testrequest');

    String requestid=_databaseReference.push().key.toString();
    _databaseReference.child(requestid).set({
      'requestid':requestid,
      'reportimg':imageUrl,
      'username':userModel!.name,
      'userphone':userModel!.userPhone,
      'result':'pending',
      'time': formattedDateTime,
      'timestamp': millisecondsSinceEpoch,
      'service':'फसलो का रोग स्कैन'
    });
    _userdatabaseReference.child(requestid).set({
      'requestid':requestid,
      'reportimg':imageUrl,
      'username':userModel!.name,
      'userphone':userModel!.userPhone,
      'result':'pending',
      'time': formattedDateTime, // Convert DateTime to a string
      'timestamp': millisecondsSinceEpoch,
      'service':'फसलो का रोग स्कैन'
    });
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submitted Successfully Wait for Response'),
        ),
      );
      isupLoading = false; // Set isLoading to false after submission
    });
  }

@override
  void initState() {
    // TODO: implement initState
  getUserDetails();
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        elevation: 2,
        title: Text('फसलों की सलाह',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/camscan.png',width: 200,height: 250,),
            SizedBox(height: 10,),

            Align(alignment:Alignment.center,child: Text('रोग का पता लगाने के लिए \nअपनी फसल के पत्ते की तस्वीर लें',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),)),
            SizedBox(height: 5,),
            InkWell(onTap:(){ _pickImage(picker.ImageSource.camera);},
                child: Container(
                  width: double.infinity,
                    margin: EdgeInsets.all(15),
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                         Icon(Icons.camera_alt,size:
                           150,),
                          Text('Leaf Photo',style: TextStyle(color: Colors.green),)
                        ],
                      ),
                    ))),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: (){
                submittestreport();

              }, child: isupLoading
                  ? CircularProgressIndicator() // Show CircularProgressIndicator if loading
                  : Text(
                'Upload and Submit',
                style: TextStyle(color: Colors.white),
              ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Change the background color to green
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
