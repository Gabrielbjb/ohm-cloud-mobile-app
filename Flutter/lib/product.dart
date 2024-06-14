import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:projectflutter1/productdetail.dart';

import 'network.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> categories = [];
  List<dynamic> products = [];
  int selectedCategoryId = -1;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    var response = await http.get(Uri.parse("$baseUrl/api/categories"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      setState(() {
        categories = responseData["data"];
      });
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
    }
  }

  Future<void> fetchProducts() async {
    var response = await http.get(Uri.parse("$baseUrl/api/products"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      setState(() {
        products = responseData["data"];
      });
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
    }
  }

  List<dynamic> getFilteredProducts() {
    if (selectedCategoryId == -1) {
      return products;
    } else {
      return products.where((product) => product["id_kategori"] == selectedCategoryId).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List The All Of Our Product"),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category["id"];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: selectedCategoryId == category["id"] ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category["nama_kategori"],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Products
          Expanded(
            child: products.isNotEmpty
                ? GridView.count(
              crossAxisCount: 2, // Two columns
              shrinkWrap: true,
              children: List.generate(
                getFilteredProducts().length,
                    (index) {
                  var product = getFilteredProducts()[index]; // Each product

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailPage(productId: product["id"]));
                    },
                    child: Card(
                      margin: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Image.network(product["gambar"]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            product["nama_barang"] ?? "No Name",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Harga Rp. " + product["harga"].toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
