import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ganga_kosi/Pages/HomePage.dart';
import 'package:ganga_kosi/Pages/ProductCateogoryList.dart';
import 'package:ganga_kosi/Pages/ProductDetails.dart';
import 'package:ganga_kosi/Pages/Services/SellRequest.dart';

import '../Model/Product.dart';
import '../Model/UserModel.dart';
import '../Pages/Pagerouter.dart';
import '../Pages/Services/CropsPredict.dart';
import '../Pages/SigninBottomSheetWidget.dart';
import '../Utils/Toast.dart';
import 'PosterSlider.dart';





class ProductsList extends StatefulWidget {
  const ProductsList({Key? key}) : super(key: key);

  @override
  State<ProductsList> createState() => _ProductsListState();
}
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber.toString().substring(3, 13);
class _ProductsListState extends State<ProductsList> {


  late DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi/products');
  String? _selectedGender;
  String? _selectedState;
  TextEditingController grainnamecontroller = TextEditingController();
  TextEditingController grainqtycontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobcontroller = TextEditingController();
  TextEditingController gendercontroller = TextEditingController();
  TextEditingController villagenamecontroller = TextEditingController();
  TextEditingController postnamecontroller = TextEditingController();
  TextEditingController pincodecontroller = TextEditingController();
  TextEditingController districtnamecontroller = TextEditingController();
  TextEditingController statenamecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchData();
  }
  List<ProductModel> products = [];

  void fetchData() async {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;
      products.clear();
      if (data != null) {
        // Ensure data is a map before using forEach
        if (data is Map) {
          data.forEach((key, value) {
            products.add(ProductModel.fromJson(Map<String, dynamic>.from(value)));
          });
        }
      }
      setState(() {});
    });
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Container(
                margin: EdgeInsets.only(bottom: 4,top: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow, // Set the background color
                  borderRadius: BorderRadius.circular(10), // Set the border radius
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16,), // Add padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart,color: Colors.green,),
                    SizedBox(width: 8), // Add space between icon and text
                    Text('खरीदे',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4,top: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_florist,color: Colors.yellow,),
                    SizedBox(width: 8),
                    Text('बेचे',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  ],
                ),
              ),
            ],
            indicatorColor: Colors.green, // Set the indicator color
            labelColor: Colors.black, // Set the text color of selected tab
            unselectedLabelColor: Colors.white, // Set the text color of unselected tabs
          )


        ),
        body: TabBarView(
          children: [
              itemlist(),
            Sellwidget()
          ],
        ),
      ),
    );
  }



  Widget itemlist(){

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PosterSliderWidget(),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Align(alignment:Alignment.topLeft,child: Text('Cateogory',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)),
              ),
              Container(
                  margin: EdgeInsets.only(left: 4,right: 4),
                  height:130,child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ProductCatWidget(),
              )),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15,left: 10),
                child: Align(alignment:Alignment.topLeft,child: Text('Products by Ganga Koshi',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)),
              ),
              Container(
                height:(products.length/2)*220 ,
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, // Adjust for desired number of columns
                  children: products.map((product) => productCard(product)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget Sellwidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/grain.jpg',height: 250,),




            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(onPressed: (){

                  user=FirebaseAuth.instance.currentUser;
                  if (user != null) {
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
                        return SellRequestForm();
                      },
                    );
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

                }, child: Text('Sell',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),), style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),),
              ),
            ),


          ],
        ),
      ),
    );
  }



  Widget productCard(ProductModel product) {
    return InkWell(
      onTap: (){
        Navigator.push(context, customPageRoute(ProductDetails(productid: product.productid)));
      },
      child: Card(
        margin: EdgeInsets.all(20),
        elevation: 4,
        surfaceTintColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Image.network(product.productimage,height: 115,),
            ),
            Text(product.productname,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
            Container(
              child: Text(
                'कीमत- ₹${product.productcost}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '${calculatePercentage(product.productmrp, product.productcost).toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 10,
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
                    '${product.productmrp}',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        // Add this line
                        decorationColor: Colors.blueGrey,
                        decorationThickness: 3// Add this line if you want the strike-through color to be pink
                    ),
                  ),
                ),


              ],
            ),
            SizedBox(height: 4,)

          ],
        ),
      ),
    );
  }

  Widget ProductCatWidget() {
    Set<String> uniqueSizes = <String>{};
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query: _databaseReference.orderByChild('productcat').limitToFirst(50),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        final data = snapshot.value;

        if (data != null && data is Map) {
          String productcat = data['productcat'].toString();
          String productimage=data['productimage'].toString();

          // Check if the city is not already added to the set
          if (!uniqueSizes.contains(productcat)) {
            uniqueSizes.add(productcat);
            return GestureDetector(
                onTap: () {
                  Navigator.push(context, customPageRoute(ProductCateogoryList(productcat: productcat)));
                },
                child: Container(

                  width: 120,
                  height: 100,
                  margin: EdgeInsets.only(left: 2,right: 2),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2,right: 2),
                    child: GridTile(
                      footer: Container(
                        height: 20, // Adjust the height as needed
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Text(
                          productcat,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,

                        backgroundImage: NetworkImage(
                          productimage,
                          // Replace with your image URL
                        ),
                      ),
                    ),
                  ),
                ));
          }
        }

        return const SizedBox(); // Return an empty container if data is not in the expected format or if the city is a repetition.
      },
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








