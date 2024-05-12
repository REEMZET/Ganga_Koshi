import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ganga_kosi/Utils/Toast.dart';

import '../../Model/UserModel.dart';

class SellRequestForm extends StatefulWidget {
  @override
  _SellRequestFormState createState() => _SellRequestFormState();
}
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
late DatabaseReference userRef;
class _SellRequestFormState extends State<SellRequestForm> {
  final TextEditingController grainnamecontroller = TextEditingController();
  final TextEditingController grainqtycontroller = TextEditingController();
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController mobcontroller = TextEditingController();
  final TextEditingController villagenamecontroller = TextEditingController();
  final TextEditingController postnamecontroller = TextEditingController();
  final TextEditingController pincodecontroller = TextEditingController();
  final TextEditingController districtnamecontroller = TextEditingController();

  String? _selectedGender;
  String? _selectedState;
  UserModel? userModel;
  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    userRef = FirebaseDatabase.instance
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
        String Address=udata['Address'].toString();
        setState(() {
          namecontroller.text = userModel!.name;
          mobcontroller.text = userModel!.userPhone;
          Map<String, String> parsedAddress = getAddress(Address);


          villagenamecontroller.text=parsedAddress['villageName']!;
          postnamecontroller.text=parsedAddress['postName']!;
          pincodecontroller.text=parsedAddress['pinCode']!;
          districtnamecontroller.text=parsedAddress['districtName']!;
          _selectedGender=parsedAddress['selectedGender']!;
          _selectedState=parsedAddress['selectedState']!;
          completer.complete();
        });
      }
    });
    return completer.future;
  }
  @override
  void initState() {
    // TODO: implement initState
    getUserDetails();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10,
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Image.asset('assets/images/grain.jpg',height: 100,),
              Text('अपना अनाज बेचने के लिए अपना विवरण दर्ज करें',style: TextStyle(fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: grainnamecontroller,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'अनाज का नाम',
                          labelStyle: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.local_florist,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: grainqtycontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'मात्रा Kg',
                          labelStyle: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: namecontroller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'नाम',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
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
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: mobcontroller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        prefixIcon: Icon(
                          Icons.people,
                          color: Colors.black,
                        ),
                      ),
                      value: _selectedGender,
                      items: <String>['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                    ),
                  ),
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
                        controller: pincodecontroller,
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
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      submitSellRequest();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Change the background color to green
                    ),
                    child: Text(
                      'Sell Request',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitSellRequest() {
    DateTime now = DateTime.now();
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    if (grainnamecontroller.text.isEmpty ||
        grainqtycontroller.text.isEmpty ||
        namecontroller.text.isEmpty ||
        mobcontroller.text.isEmpty ||
        villagenamecontroller.text.isEmpty ||
        postnamecontroller.text.isEmpty ||
        pincodecontroller.text.isEmpty ||
        districtnamecontroller.text.isEmpty ||
        _selectedState == null ||
        _selectedGender == null) {
     ToastWidget.showToast(context, 'All fields are required');
      return;
    }

    late DatabaseReference _databaseReference =
    FirebaseDatabase.instance.reference().child('GangaKoshi/Admin');
    _databaseReference.child('sell_requests').push().set({
      'grain_name': grainnamecontroller.text,
      'grain_quantity': grainqtycontroller.text,
      'name': namecontroller.text,
      'mobile_number': mobcontroller.text,
      'gender': _selectedGender,
      'village_name': villagenamecontroller.text,
      'post_office': postnamecontroller.text,
      'pin_code': pincodecontroller.text,
      'district': districtnamecontroller.text,
      'state': _selectedState,
      'time': now.toIso8601String(),
      'timestamp': millisecondsSinceEpoch,
      'status': 'Pending'
    }).then((_) {
      updateAddress();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sell request submitted successfully'),
        ),
      );

      grainnamecontroller.clear();
      grainqtycontroller.clear();
      namecontroller.clear();
      mobcontroller.clear();
      villagenamecontroller.clear();
      postnamecontroller.clear();
      pincodecontroller.clear();
      districtnamecontroller.clear();
      setState(() {
        _selectedGender = null;
        _selectedState = null;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting sell request: $error'),
        ),
      );
    });
  }




  void updateAddress() {
    userRef.child('Address').set('$_selectedGender,${villagenamecontroller.text},${postnamecontroller.text},'
        '${pincodecontroller.text},${districtnamecontroller.text},$_selectedState');
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
