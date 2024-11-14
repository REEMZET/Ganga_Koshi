import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_cropper/image_cropper.dart'; // Added import
import 'package:intl/intl.dart';

import '../../Model/UserModel.dart';
import '../Pagerouter.dart';
import '../SearchPage.dart';
import '../SigninBottomSheetWidget.dart';
import '../TestRequest.dart';

class CropPredict extends StatefulWidget {
  @override
  _CropPredictState createState() => _CropPredictState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

class _CropPredictState extends State<CropPredict> {
  File? _image;
  TextEditingController nitrogenController = TextEditingController();
  TextEditingController phosphorousController = TextEditingController();
  TextEditingController potassiumController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  TextEditingController pHController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  bool isLoading = false; // Add a boolean to track loading state
  bool isupLoading = false;
  UserModel? userModel;

// Step 1: Define the list of districts
  final List<String> biharDistricts = [
    'Araria',
    'Arwal',
    'Aurangabad',
    'Banka',
    'Begusarai',
    'Bhagalpur',
    'Bihar Sharif',
    'Buxar',
    'Darbhanga',
    'East Champaran',
    'Gaya',
    'Gopalganj',
    'Jamui',
    'Jehanabad',
    'Khagaria',
    'Kishanganj',
    'Lakhisarai',
    'Madhepura',
    'Madhubani',
    'Munger',
    'Nalanda',
    'Nawada',
    'Patna',
    'Purnia',
    'Rohtas',
    'Saharsa',
    'Samastipur',
    'Saran',
    'Sheikhpura',
    'Sheohar',
    'Sitamarhi',
    'Supaul',
    'Vaishali',
    'West Champaran',
  ];

  // List of languages to display in the dropdown

  bool _validateFields() {
    if (nitrogenController.text.isEmpty ||
        phosphorousController.text.isEmpty ||
        potassiumController.text.isEmpty ||
        pHController.text.isEmpty ||
        districtController.text.isEmpty) {
      // Show error snack bar if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('कृपया सभी स्थानों को भरें।'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> CropPredictfun() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      isLoading = true;
    });


    var data = json.encode({
      "nitrogen": int.parse(nitrogenController.text),
      "phosphorous": int.parse(phosphorousController.text),
      "pottasium": int.parse(potassiumController.text),
      "ph": double.parse(pHController.text),
      "district": districtController.text,
    });

    try {
      var headers = {
        'Content-Type': 'application/json'
      };

      var dio = Dio();
      var response = await dio.request(
        'http://51.20.3.105/crop-predict',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      }
      else {
        print(response.statusMessage);
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null && responseData.containsKey('prediction')) {
          setState(() {
            resultController.text = responseData['prediction'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to get result from response');
        }
      } else {
        throw Exception('Failed to load data. Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get recommendation. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> predictCrop(File? imageFile, String district) async {
    // Check if an image file is selected
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected. Please select an image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if(districtController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Any District selected. Please select District.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isupLoading = true; // Set loading state to true when prediction starts
    });

    try {
      // Create FormData with a single MultipartFile for the image
      var data = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'image.jpg'), // Use a valid filename
        'district': district,
      });

      var dio = Dio();
      var response = await dio.post(
        'http://51.20.3.105/crop-predict',
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null && responseData.containsKey('prediction')) {
          setState(() {
            resultController.text = responseData['prediction'];
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get prediction. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isupLoading = false; // Ensure loading state is reset after completion
      });
    }
  }


  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('GangaKoshi/User/${user!.uid}');
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
    if (user != null) {
      phoneNumber = user.phoneNumber.toString();
    } else {
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        elevation: 4,
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
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
                  SignInBottomSheet(onSuccessLogin: () {
                    setState(() {
                      user = FirebaseAuth.instance.currentUser;
                      phoneNumber = user?.phoneNumber.toString().substring(3, 13);
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
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Choose Image'),
        ),
      );
      return;
    }
    predictCrop(_image, "Motihari");
  }

  Future<void> submitTestPredictionreport(File? imageFile, UserModel? userModel, BuildContext context,String result) async {
    if (imageFile == null || userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image and ensure user information is available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Upload image to Firebase Storage
    final FirebaseStorage _storage = FirebaseStorage.instance;
    var uploadTask = _storage
        .ref()
        .child('Images/reportimages/${DateTime.now().millisecondsSinceEpoch}.jpg')
        .putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();

    // Prepare request data
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(now);
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi').child('Admin/testrequest');
    DatabaseReference _userdatabaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi/User/').child(userModel.uid).child('testrequest');

    String requestid = _databaseReference.push().key.toString();
    _databaseReference.child(requestid).set({
      'requestid': requestid,
      'reportimg': imageUrl,
      'username': userModel.name,
      'userphone': userModel.userPhone,
      'result': result,
      'time': formattedDateTime,
      'timestamp': millisecondsSinceEpoch,
      'service': 'फ़सलों के सलाह',
      'uid': userModel.uid
    });

    _userdatabaseReference.child(requestid).set({
      'requestid': requestid,
      'reportimg': imageUrl,
      'username': userModel.name,
      'userphone': userModel.userPhone,
      'result': result,
      'time': formattedDateTime,
      'timestamp': millisecondsSinceEpoch,
      'service': 'फ़सलों के सलाह'
    });

    // Show success message and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submitted Successfully. Wait for Response.'),
      ),
    );
    Navigator.push(context, customPageRoute(TestRequest()));
  }

  Future<void> _pickImage(picker.ImageSource source) async {
    final imagePicker = picker.ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      // Crop the image using ImageCropper
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,

        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 4.5), // Custom aspect ratio
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Choose Report Image',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path); // Convert CroppedFile to File
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (user != null) {
      getUserDetails();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          'फसलों की सलाह',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/cropspre.png', width: 100, height: 110,),
              SizedBox(height: 10,),

              Align(
                  alignment: Alignment.center,
                  child: Text(
                    'फ़सलों के सलाह के लिए \nअपनी मिटी परीक्षण रिपोर्ट अपलोड करें',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                  )
              ),
              SizedBox(height: 5,),
              InkWell(
                  onTap: () { _pickImage(picker.ImageSource.gallery); },
                  child: Container(
                      margin: EdgeInsets.all(6),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            if (_image != null)
                              Container(
                                height: 200,
                                width: 80,
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.fill,
                                ),
                              )
                            else
                              Image.asset('assets/images/upload.png', width: 100, height: 100,),
                            Text('Soil report', style: TextStyle(color: Colors.green),)
                          ],
                        ),
                      )
                  )
              ),
              buildDistrictDropdown(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    submittestreport();
                  },
                  child: isupLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) // Show CircularProgressIndicator if loading
                      : Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Change the background color to green
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    'या फ़िर',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                  )
              ),
              SizedBox(height: 16,),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    '👇 मात्रा दर्ज करे',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )
              ),
              SizedBox(height: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: nitrogenController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'नाइट्रोजन की मात्रा',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: phosphorousController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'फॉस्फोरस की मात्रा',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: potassiumController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'पोटैशियम की मात्रा',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: pHController,
                        keyboardType: TextInputType.text,
                        maxLength: 30,
                        decoration: InputDecoration(
                          labelText: 'पीएच मान',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.drag_indicator,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
             buildDistrictDropdown(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    CropPredictfun();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Change the background color to green
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) // Show CircularProgressIndicator if loading
                      : Text(
                    'सलाह प्राप्त करे',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              resultController.text.isNotEmpty
                  ? HtmlWidget(
                'Result:- ${resultController.text}',
                textStyle: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold,),
              )
                  : Container(), // Show HtmlWidget only if result is not empty
            ],
          ),
        ),
      ),
    );
  }



  Widget buildDistrictDropdown() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select District',
          labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
        value: districtController.text.isNotEmpty ? districtController.text : null,
        onChanged: (String? newValue) {
          setState(() {
            districtController.text = newValue ?? ''; // Update the districtController text
          });
        },
        items: biharDistricts.map<DropdownMenuItem<String>>((String district) {
          return DropdownMenuItem<String>(
            value: district,
            child: Text(district),
          );
        }).toList(),
        // Customize the dropdown appearance
        icon: Icon(Icons.arrow_drop_down),
        isExpanded: true,
      ),
    );
  }
}


