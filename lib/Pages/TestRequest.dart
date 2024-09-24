
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';

class TestRequest extends StatefulWidget {
  const TestRequest({super.key});

  @override
  State<TestRequest> createState() => _TestRequestState();
}

User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
class _TestRequestState extends State<TestRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Report'),elevation: 2,),
      body: Column(
        children: [
  RequestList()
        ],
      ),
    );

  }

  Widget RequestList() {
    final ref = FirebaseDatabase.instance.ref(
        '/GangaKoshi/User/${user!.uid}/testrequest');


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
          String reportimg = snapshot.child('reportimg').value.toString();
          String requestid = snapshot.child('requestid').value.toString();
          String result = snapshot.child('result').value.toString();
          String service = snapshot.child('service').value.toString();
          String time = snapshot.child('time').value.toString();
          String timestamp = snapshot.child('timestamp').value.toString();
          String username = snapshot.child('username').value.toString();
          String userphone = snapshot.child('userphone').value.toString();

          return Card(
            elevation: 0,
            margin: EdgeInsets.all(4),
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        topRight: Radius.circular(6.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Ganga Koshi Private Ltd.',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold,color: Colors.white)),
                                  Text('Date:-$time',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black54
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left: 4,right: 4,top: 2),
                    child: Row(
                      children: [
                        SizedBox(width:1),
                        Image.network(reportimg, height: 170, width: 120, fit: BoxFit.fill),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis, // Set overflow behavior
                                maxLines: 1,
                              ),
                              Text(
                                'Result: $result',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: result == 'pending' ? Colors.red : Colors.green,
                                ),
                                overflow: TextOverflow.ellipsis, // Set overflow behavior
                                maxLines: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1,color: Colors.grey,)

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
