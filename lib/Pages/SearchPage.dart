import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Model/Product.dart';
import 'Pagerouter.dart';
import 'ProductDetails.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  late DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('GangaKoshi/products');
  TextEditingController searchController = TextEditingController();
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;
      products.clear();
      filteredProducts.clear();
      if (data != null) {
        if (data is Map) {
          data.forEach((key, value) {
            products.add(ProductModel.fromJson(Map<String, dynamic>.from(value)));
          });
          filteredProducts = products; // Initially, all products are shown
        }
      }
      setState(() {});
    });
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      filteredProducts = products;
    } else {
      filteredProducts = products
          .where((product) =>
      product.productname.toLowerCase().contains(query.toLowerCase()) ||
          product.productcost.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: Text('Search Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterSearchResults(value); // Filter products based on query
              },
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by product name or cost',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return productCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget productCard(ProductModel product) {
    return InkWell(
      onTap: () {
        Navigator.push(context, customPageRoute(ProductDetails(productid: product.productid)));
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
                        decorationColor: Colors.blueGrey,
                        decorationThickness: 3),
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
