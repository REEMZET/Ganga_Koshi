import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
class _MyBookingState extends State<MyBooking> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('My Orders'),elevation: 1,),
      body: Column(
        children: [
          OrderList(),
        ],
      ),
    );
  }

  Widget OrderList() {
    final ref = FirebaseDatabase.instance.ref(
        '/GangaKoshi/User/$phoneNumber/orders');


    return Expanded(
      child: FirebaseAnimatedList(
        query: ref,
        sort: (a, b) {
          // Parse timestamp from snapshots and cast to int
          int timestampA = int.parse(a.child('timestamp').value.toString());
          int timestampB = int.parse(b.child('timestamp').value.toString());

          // Compare timestamps
          return timestampB.compareTo(timestampA); // Sorting in descending order (newer timestamp first)
        },

        itemBuilder: (context, snapshot, animation, index) {
          String address = snapshot.child('address').value.toString();
          String deliverycharge = snapshot.child('deliverycharge').value.toString();
          String gst = snapshot.child('gst').value.toString();
          String itemimg = snapshot.child('itemimg').value.toString();
          String itemname = snapshot.child('itemname').value.toString();
          String itemquantity = snapshot.child('itemquantity').value.toString();
          String mobile_number = snapshot.child('mobile_number').value.toString();
          String name = snapshot.child('name').value.toString();
          String orderid = snapshot.child('orderid').value.toString();
          String ordertime = snapshot.child('ordertime').value.toString();
          String pin_code = snapshot.child('pin_code').value.toString();
          String productcharge = snapshot.child('productcharge').value.toString();
          String status = snapshot.child('status').value.toString();
          String timestamp = snapshot.child('timestamp').value.toString();
          String totalprice=snapshot.child('totalprice').value.toString();


          return Card(
            elevation: 0,
            margin: EdgeInsets.all(10),
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Row(
                    children: [
                      _buildIconForStatus(status),
                      SizedBox(width: 4,),// Use a function to build the icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$status',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                          Text('Date-$ordertime', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),

                  Card(
                    elevation: 0,
                    surfaceTintColor: AppColors.primaryColor,
                    margin: EdgeInsets.all(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Image.network(itemimg,height: 90,width: 80,),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemname,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      ':- ' + itemquantity,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Total Price',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      ':- ₹' + totalprice,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Payment Option :-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'COD',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),


                                SizedBox(width: 4),
                                Text(
                                  address+pin_code,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                  ),
                                  overflow: TextOverflow.ellipsis, // Set overflow behavior
                                  maxLines:2, // Limit to 1 line
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black12,
                    height: 0.5,
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _buildIconForStatus(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'Pending':
        iconData = Icons.pending_actions;
        iconColor = Colors.orange;
        break;
      case 'Confirm':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'Shipped':
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      case 'Out for Delivery':
        iconData = Icons.delivery_dining;
        iconColor = Colors.blue;
        break;
      case 'Delivered':
        iconData = Icons.done_all;
        iconColor = Colors.green;
        break;
      case 'Canceled':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.black;
        break;
    }

  

    return Icon(
      iconData,
      size: 35,
      color: iconColor,
    );
  }
}
