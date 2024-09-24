import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Model/UserModel.dart';
import '../Pagerouter.dart';
import '../SearchPage.dart';
import '../SoilTestRequest.dart';

class SoilTest extends StatefulWidget {
  const SoilTest({super.key});

  @override
  State<SoilTest> createState() => _SoilTestState();
}
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
late DatabaseReference userRef;
UserModel? userModel;
class _SoilTestState extends State<SoilTest> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController pinCodeController = TextEditingController();
  final TextEditingController postnamecontroller = TextEditingController();
  final TextEditingController districtnamecontroller = TextEditingController();
  final TextEditingController villagenamecontroller = TextEditingController();
  String? _selectedState;
  late String formattedDateTime;


  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    userRef = FirebaseDatabase.instance
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
        String Address=udata['Address'].toString();
        setState(() {
          nameController.text = userModel!.name;
          phoneController.text = userModel!.userPhone;
          Map<String, String> parsedAddress = getAddress(Address);
          villagenamecontroller.text=parsedAddress['villageName']!;
          postnamecontroller.text=parsedAddress['postName']!;
          pinCodeController.text=parsedAddress['pinCode']!;
          districtnamecontroller.text=parsedAddress['districtName']!;
          _selectedState=parsedAddress['selectedState']!;

          completer.complete();
        });
      }
    });
    return completer.future;
  }
  @override
  void initState() {
    super.initState();
    getUserDetails();
    formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('मिट्टी परिक्षण'),elevation: 2,),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
              left: 10,
              right: 10,
            ),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/soiltest.png'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
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
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.black,
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
                            controller: villagenamecontroller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'गाँव का नाम',
                              labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.black,
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
                            controller: postnamecontroller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'पोस्ट ऑफ़िस का नाम',
                              labelStyle: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.location_city,
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
                            controller: pinCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Pin Code',
                              labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.location_pin,
                                color: Colors.black,
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
                            controller: districtnamecontroller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'जिले का नाम',
                              labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'राज्य का नाम',
                              labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ),
                            ),
                            value: _selectedState,
                            items: <String>[
                              'Andhra Pradesh',
                              'Arunachal Pradesh',
                              'Assam',
                              'Bihar',
                              'Chhattisgarh',
                              'Goa',
                              'Gujarat',
                              'Haryana',
                              'Himachal Pradesh',
                              'Jharkhand',
                              'Karnataka',
                              'Kerala',
                              'Madhya Pradesh',
                              'Maharashtra',
                              'Manipur',
                              'Meghalaya',
                              'Mizoram',
                              'Nagaland',
                              'Odisha',
                              'Punjab',
                              'Rajasthan',
                              'Sikkim',
                              'Tamil Nadu',
                              'Telangana',
                              'Tripura',
                              'Uttar Pradesh',
                              'Uttarakhand',
                              'West Bengal',
                              'Andaman and Nicobar Islands',
                              'Chandigarh',
                              'Dadra and Nagar Haveli',
                              'Delhi',
                              'Lakshadweep',
                              'Puducherry',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedState = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextFormField(
                      readOnly: true, // Make the field read-only
                      controller: TextEditingController(text: formattedDateTime), // Set initial value to formattedDateTime
                      keyboardType: TextInputType.datetime, // Use datetime keyboard type
                      decoration: InputDecoration(
                        labelText: 'Booking Date and Time', // Change label text
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((selectedTime) {
                              if (selectedTime != null) {
                                // Combine selected date and time and format it
                                setState(() {
                                  formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(
                                      DateTime(
                                          selectedDate.year,
                                          selectedDate.month,
                                          selectedDate.day,
                                          selectedTime.hour,
                                          selectedTime.minute));
                                });
                              }
                            });
                          }
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, bottom: 10),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          BookSoilTest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Change the background color to green
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                              color: Colors.white), // Set text color to white
                        ),
                      ),
                    ),
                  ),
                  Text('')
                ],
              ),
            ),
          ),
        )
    );
  }


  void BookSoilTest() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(now);

    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;


    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        villagenamecontroller.text.isEmpty ||
        postnamecontroller.text.isEmpty||
        districtnamecontroller.text.isEmpty||
        _selectedState==null||
        pinCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required'),
        ),
      );
      return; // Exit the function early
    }
    updateAddress();
    DatabaseReference _databaseReference = FirebaseDatabase.instance
        .reference()
        .child('GangaKoshi')
        .child('Admin/SoilTestRequest');
    final usertestref = FirebaseDatabase.instance.ref(
        '/GangaKoshi/User/${user!.uid}/soiltestrequest');
    String orderid = _databaseReference.push().key.toString();
    usertestref.child(orderid).set({
      'name': nameController.text,
      'mobile_number': phoneController.text,
      'address':'${villagenamecontroller.text}, ${postnamecontroller.text}, ${districtnamecontroller.text} ,$_selectedState!',
      'pin_code': pinCodeController.text,
      'slot':formattedDateTime,
      'bookid': orderid,
      'Status':'Confirm',
      'bookingtime': formattedDate, // Convert DateTime to a string
      'timestamp': millisecondsSinceEpoch,
    });

    _databaseReference.child(orderid).set({
      'name': nameController.text,
      'mobile_number': phoneController.text,
      'address':'${villagenamecontroller.text}, ${postnamecontroller.text}, ${districtnamecontroller.text} ,$_selectedState!',
      'pin_code': pinCodeController.text,
      'slot':formattedDateTime,
      'bookid': orderid,
      'Status':'Confirm',
      'bookingtime': formattedDate, // Convert DateTime to a string
      'timestamp': millisecondsSinceEpoch,
      'uid':user!.uid,
    }).then((_) {
      nameController.clear();
      phoneController.clear();
      villagenamecontroller.clear();
      districtnamecontroller.clear();
      postnamecontroller.clear();
      pinCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Soil testing Booked Successfully'),
        ),
      );
      Navigator.push(context, customPageRoute(SoilTestRequest()));
      setState(() {});
    }).catchError((error) {
      // Show an error message if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
        ),
      );
    });
  }

  void updateAddress() {
    userRef.child('Address').set('Male,${villagenamecontroller.text},${postnamecontroller.text},'
        '${pinCodeController.text},${districtnamecontroller.text},$_selectedState');
  }
  Map<String, String> getAddress(String addressString) {
    List<String> addressComponents = addressString.split(',');
    String selectedGender = addressComponents[0];
    String villageName = addressComponents[1];
    String postName = addressComponents[2];
    String pinCode = addressComponents[3];
    String districtName = addressComponents[4];
    String selectedState = addressComponents[5];

    return {
      'selectedGender': selectedGender,
      'villageName': villageName,
      'postName': postName,
      'pinCode': pinCode,
      'districtName': districtName,
      'selectedState': selectedState,
    };
  }
}
