import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ganga_kosi/Model/UserModel.dart';
import 'package:ganga_kosi/Widget/RecomendationsProducts.dart';
import 'package:intl/intl.dart';

import '../Utils/Toast.dart';
import '../Widget/DashedDivider.dart';
import 'SigninBottomSheetWidget.dart';

class ProductDetails extends StatefulWidget {
  final String productid;

  ProductDetails({required this.productid});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);

late DatabaseReference userRef;

class _ProductDetailsState extends State<ProductDetails> {
  late DatabaseReference _databaseReference = FirebaseDatabase.instance
      .reference()
      .child('GangaKoshi/products')
      .child(widget.productid);
  late String productname;
  late String productimage;
  late String productid;
  late String productcost;
  late String productmrp;
  late String productdesc;
  late String productcat;
  late String productgst;
  late String deliverycharge;

  void fetchData() async {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null) {
        productimage = event.snapshot.child('productimage').value.toString();
        productname = event.snapshot.child('productname').value.toString();
        productcost = event.snapshot.child('productcost').value.toString();
        productmrp = event.snapshot.child('productmrp').value.toString();
        productdesc = event.snapshot.child('productdesc').value.toString();
        productcat = event.snapshot.child('productcat').value.toString();
        productgst = event.snapshot.child('gst').value.toString();
        productid = event.snapshot.child('productid').value.toString();
        deliverycharge =
            event.snapshot.child('deliverycharge').value.toString();

        setState(() {});
      }
    });
  }


  @override
  void initState() {
    super.initState();

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Prodcut Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.network(
                productimage,
                height: 290,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              productname,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '${calculatePercentage(productmrp, productcost).toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  width: 2,
                ),
                Container(
                  child: Text(
                    '${productmrp}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        // Add this line
                        decorationColor: Colors.blueGrey,
                        decorationThickness:
                            3 // Add this line if you want the strike-through color to be pink
                        ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  child: Text(
                    'कीमत- ₹${productcost}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Product Descriptions',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration:
                        TextDecoration.underline, // Adding underline decoration
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: productdesc.split(r'\n').length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text(
                            '\u2022', // Bullet point Unicode character
                            style: TextStyle(
                                fontSize: 20.0, color: Colors.black87),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            productdesc.split(r'\n')[index],
                            style: TextStyle(
                                fontSize: 17.0, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {

                      user=FirebaseAuth.instance.currentUser;
                      if(user!=null){
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
                            return PlaceOrder(
                              producturl: productimage,
                              productitle: productname,
                              productcost: productcost,
                              gst: productgst,
                              deliverycharge: deliverycharge,
                            );
                          },
                        );
                      }else{
                        Navigator.pop(context);
                        ToastWidget.showToast(context, 'please Login');
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
                                      });
                                    },)
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }







                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Colors.green, // Change the background color to green
                    ),
                    child: Text(
                      'Order Now',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'More Products',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration:
                        TextDecoration.underline, // Adding underline decoration
                  ),
                ),
              ),
            ),
            Container(
                height: 200,
                child: RecomendationProduct(productcat: productcat))
          ],
        ),
      ),
    );
  }

  double calculatePercentage(String mrpString, String discountedPriceString) {
    try {
      double mrp = double.parse(mrpString);
      double discountedPrice = double.parse(discountedPriceString);

      if (mrp <= 0 || discountedPrice < 0 || discountedPrice > mrp) {
        throw ArgumentError(
            "Invalid input values. Make sure MRP > 0, discountedPrice >= 0, and discountedPrice <= MRP.");
      }

      double percentageOff = ((mrp - discountedPrice) / mrp) * 100;
      return percentageOff;
    } catch (e) {
      throw ArgumentError(
          "Invalid input values. Please provide valid numeric values for MRP and discountedPrice.");
    }
  }
}

class PlaceOrder extends StatefulWidget {
  final String producturl;
  final String productitle;
  final String productcost;
  final String gst;
  final String deliverycharge;



  PlaceOrder({
    required this.producturl,
    required this.productitle,
    required this.productcost,
    required this.gst,
    required this.deliverycharge,


  });

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}
TextEditingController villagenamecontroller = TextEditingController();
TextEditingController postnamecontroller = TextEditingController();
TextEditingController districtnamecontroller = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController pinCodeController = TextEditingController();

String? _selectedState;
class _PlaceOrderState extends State<PlaceOrder> {
  int _selectedQuantity = 1;
  Future<void> getUserDetails() async {
    Completer<void> completer = Completer<void>();
    userRef = FirebaseDatabase.instance
        .reference()
        .child('GangaKoshi/User/$phoneNumber');
    userRef.onValue.listen((event) {
      final udata = event.snapshot.value;
      if (udata != null) {
        Map<dynamic, dynamic> data = udata as Map<dynamic, dynamic>;
      UserModel  userModel = UserModel(
          name: data['name'] ?? '',
          userPhone: data['userphone'] ?? '',
          uid: data['uid'] ?? '',
          regDate: data['regdate'] ?? '',
          deviceId: '',
        );
        String Address=udata['Address'].toString();
        setState(() {
          Map<String, String> parsedAddress = getAddress(Address);
          villagenamecontroller.text=parsedAddress['villageName']!;
          postnamecontroller.text=parsedAddress['postName']!;
          pinCodeController.text=parsedAddress['pinCode']!;
          districtnamecontroller.text=parsedAddress['districtName']!;
          _selectedState=parsedAddress['selectedState']!;
          nameController.text = userModel.name;
          phoneController.text = userModel.userPhone;
          completer.complete();
        });
      }
    });
    return completer.future;
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

  @override
  void initState() {
    super.initState();
    getUserDetails();

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(widget.producturl, height: 150),
              Text(widget.productitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('कीमत- ₹${widget.productcost}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
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
                      child: TextFormField(
                        controller: pinCodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Pin Code',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DropdownButtonFormField<int>(
                        value: _selectedQuantity,
                        decoration: InputDecoration(
                          labelText: 'Select Quantity',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.drag_indicator,
                            color: Colors.black,
                          ),
                        ),
                        items: List.generate(10, (index) => index + 1)
                            .map((quantity) {
                          return DropdownMenuItem<int>(
                            value: quantity,
                            child: Text(quantity.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuantity = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              PaymentSummary(),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      user=FirebaseAuth.instance.currentUser;
                      if (user != null) {
                       OrderFun();
                      } else {
                        {
                          {

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
                                          });
                                        },)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Colors.green, // Change the background color to green
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
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

  Widget PaymentSummary() {
    double tproductcharge =
        double.parse(widget.productcost) * _selectedQuantity;
    return Card(
      elevation: 0,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Summary',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('cost',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black54)),
                Text('${tproductcharge.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Charges',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black54)),
                Text(
                    '${double.parse(widget.deliverycharge).toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('gst',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black54)),
                Text('${double.parse(widget.gst).toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 10),
            DashedDivider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${(tproductcharge + double.parse(widget.deliverycharge) + double.parse(widget.gst)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void OrderFun() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(now);

    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    double tproductcharge = double.parse(widget.productcost) * _selectedQuantity;

    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        villagenamecontroller.text.isEmpty ||
        postnamecontroller.text.isEmpty ||
        districtnamecontroller.text.isEmpty ||
        pinCodeController.text.isEmpty||_selectedState==null) {
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
        .child('Admin/Orders');
    DatabaseReference _userdatabaseReference = FirebaseDatabase.instance
        .reference()
        .child('GangaKoshi/User/')
        .child(phoneNumber!)
        .child('orders');
    String orderid = _databaseReference.push().key.toString();
    _databaseReference.child(orderid).set({

      'itemname': widget.productitle,
      'itemquantity': _selectedQuantity,
      'name': nameController.text,
      'mobile_number': phoneController.text,
      'address':'${villagenamecontroller.text}, ${postnamecontroller.text}, ${districtnamecontroller.text} ,$_selectedState!',
      'pin_code': pinCodeController.text,
      'totalprice': '${(tproductcharge + double.parse(widget.deliverycharge) + double.parse(widget.gst)).toStringAsFixed(2)}',
      'itemimg': widget.producturl,
      'deliverycharge':'${double.parse(widget.deliverycharge)}',
      'gst':'${double.parse(widget.gst)}',
      'productcharge':'${tproductcharge}',
      'orderid': orderid,
      'Status':'Confirm',
      'ordertime': formattedDateTime, // Convert DateTime to a string
      'timestamp': millisecondsSinceEpoch,
    }).then((_) {
      DatabaseReference userOrderRef = _userdatabaseReference.push();
      userOrderRef.set({
        'itemname': widget.productitle,
        'itemquantity': _selectedQuantity,
        'name': nameController.text,
        'mobile_number': phoneController.text,
        'address':'${villagenamecontroller.text}, ${postnamecontroller.text}, ${districtnamecontroller.text} ,$_selectedState!',
        'pin_code': pinCodeController.text,
        'totalprice': '${(tproductcharge + double.parse(widget.deliverycharge) + double.parse(widget.gst)).toStringAsFixed(2)}',
        'itemimg': widget.producturl,
        'deliverycharge':'${double.parse(widget.deliverycharge)}',
        'gst':'${double.parse(widget.gst)}',
        'productcharge':'${tproductcharge}',
        'orderid': orderid,
        'status':'Confirm',
        'ordertime': formattedDateTime, // Convert DateTime to a string
        'timestamp': millisecondsSinceEpoch,
      }).then((_) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order successfully'),
          ),
        );
        nameController.clear();
        phoneController.clear();
        villagenamecontroller.clear();
        postnamecontroller.clear();
        districtnamecontroller.clear();
        pinCodeController.clear();
        Navigator.pop(context);
        setState(() {});
      });
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
}
