import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../Pages/Pagerouter.dart';
import '../Pages/ProductDetails.dart';

class RecomendationProduct extends StatefulWidget {
  final String productcat;
   RecomendationProduct({required this.productcat});

  @override
  State<RecomendationProduct> createState() => _RecomendationProductState();
}

class _RecomendationProductState extends State<RecomendationProduct> {
  late DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi/products');



  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      scrollDirection: Axis.horizontal,
      query:  _databaseReference.orderByChild('productcat').equalTo(widget.productcat),
      itemBuilder: (context, snapshot, animation, index) {
        String  productimage = snapshot.child('productimage').value.toString();
        String productname =snapshot.child('productname').value.toString();
        String productcost = snapshot.child('productcost').value.toString();
        String productmrp = snapshot.child('productmrp').value.toString();
        String productdesc = snapshot.child('productdesc').value.toString();
        String productid=snapshot.child('productid').value.toString();
        return Container(width:170,child: InkWell(
          onTap: (){
            Navigator.push(context, customPageRoute(ProductDetails(productid: productid,)));
          },
          child: Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            surfaceTintColor: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Image.network(productimage!,height: 115,width: 100,),
                ),
                Text(productname!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                Container(
                  child: Text(
                    'कीमत- ₹${productcost}',
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
                          '${calculatePercentage(productmrp!, productcost!).toStringAsFixed(2)}%',
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
                        '${productmrp}',
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
        ));
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
