import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Model/Product.dart';
import '../Pages/Pagerouter.dart';
import '../Pages/ProductDetails.dart';

class ProductCateogoryList extends StatefulWidget {
  final String productcat;
  ProductCateogoryList({required this.productcat});

  @override
  State<ProductCateogoryList> createState() => _ProductCateogoryListState();
}

class _ProductCateogoryListState extends State<ProductCateogoryList> {
  late DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('GangaKoshi/products');

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  List<ProductModel> products = [];

  void fetchData() async {
    _databaseReference.orderByChild('productcat').equalTo(widget.productcat).onValue.listen((event) {
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.productcat),elevation: 2,),
      body: Flexible(
        child:  GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return productCard(products[index]);
          },
        ),
      ),
    );
  }
  Widget productCard(ProductModel product) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, customPageRoute(ProductDetails(productid: product.productid)));
      },
      child: Card(
        margin: EdgeInsets.all(17),
        elevation: 4,
        surfaceTintColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Image.network(
                product.productimage,
                height: 130,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                product.productname,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
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
                          fontSize: 11,
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
                        fontSize: 11,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        // Add this line
                        decorationColor: Colors.blueGrey,
                        decorationThickness: 3 // Add this line if you want the strike-through color to be pink
                    ),
                  ),
                ),
              ],
            ),

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
