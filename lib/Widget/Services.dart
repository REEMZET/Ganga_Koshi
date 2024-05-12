import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ganga_kosi/Pages/Services/FertilizerPredict.dart';
import 'package:ganga_kosi/Pages/Services/SoilTest.dart';

import '../Model/UserModel.dart';
import '../Pages/Pagerouter.dart';
import '../Pages/ProductDetails.dart';
import '../Pages/Services/CropScan.dart';
import '../Pages/Services/CropsPredict.dart';
import '../Pages/SigninBottomSheetWidget.dart';
import 'Footer.dart';




class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {





  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ReusableCardWithImage(title: 'मिट्टी परिक्षण', imagePath: 'assets/images/soiltest.png',onPressed: (){
            User? user = FirebaseAuth.instance.currentUser;
            if(user!=null){
              Navigator.push(context, customPageRoute(SoilTest()));
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

          },),
          ReusableCardWithImage(title: 'फ़सलों के सलाह', imagePath: 'assets/images/crops.jpg',onPressed: (){
            Navigator.push(context, customPageRoute(CropPredict()));
          },),
          ReusableCardWithImage(title: 'खाद सुझाव', imagePath: 'assets/images/fertu.jpg',onPressed: (){
            Navigator.push(context, customPageRoute(FertilizerForm()));
          },),
          ReusableCardWithImage(title: 'फसलो का रोग स्कैन करे', imagePath: 'assets/images/scancrops.png',onPressed: (){
            Navigator.push(context, customPageRoute(CropScan()));
          },),


          FooterWidget()
        ],
      ),
    );
  }
}




class ReusableCardWithImage extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onPressed;

  const ReusableCardWithImage({
    required this.title,
    required this.imagePath,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 250,
        width: 400,
        padding: EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 250, // Adjust the height as needed
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

