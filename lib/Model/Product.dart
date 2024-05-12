class ProductModel {
  final String productid;
  final String productname;
  final String productimage;
  final String productcost;
  final String productmrp;
  final String productdesc;

  ProductModel({
    required this.productid,
    required this.productname,
    required this.productimage,
    required this.productcost,
    required this.productmrp,
    required this.productdesc,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productid: json['productid'],
      productname: json['productname'],
      productimage: json['productimage'],
      productcost: json['productcost'],
      productmrp: json['productmrp'],
      productdesc: json['productdesc'],
    );
  }
}
