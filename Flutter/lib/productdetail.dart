import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';
import 'network.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  late AuthenticationController authController;
  late Map<String, dynamic> userData;
  late Future<Map<String, dynamic>> productData;

  @override
  void initState() {
    super.initState();
    authController = Get.find();
    userData = Map<String, dynamic>.from(authController.userData); // Convert RxMap to Map
    productData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    var response = await http.get(Uri.parse("$baseUrl/api/products/${widget.productId}"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
      throw Exception("Failed to get data");
    }
  }

  void addToCart() async {
    var responseproduct = await http.get(Uri.parse("$baseUrl/api/products/${widget.productId}"));
    if (responseproduct.statusCode == 200) {
      var responseProductData = jsonDecode(responseproduct.body);
      var productsdata = responseProductData["data"];
      final String colour = productsdata["warna"];
      final int harga = productsdata["harga"];
      final int total = harga * quantity;
      final int id = userData["id"] ?? "no id";
      var data = {
        "id_member": id,
        "id_barang": widget.productId,
        "jumlah": quantity,
        "size": 1,
        "color": colour,
        "total": total,
        "is_checkout": 0,
      };
      var response = await http.post(
        Uri.parse("$baseUrl/api/cart"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          // Successfully added to cart
          Get.snackbar("Success", "Product added to cart");
        } else {
          Get.snackbar("Error", "Failed to add product to cart");
          debugPrint('Error: $responseData');
        }
      } else {
        Get.snackbar("Error", "Failed to add product to cart");
      }
    } else {
      Get.snackbar("Error", "Failed to get product data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: productData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  var products = snapshot.data as Map<String, dynamic>;
                  var product = products["data"];
                  // var image = product["gambar"];
                  //
                  // Uint8List imageBytes;
                  // try {
                  //   imageBytes = base64Decode(image);
                  // } catch (e) {
                  //   print("Error decoding Base64 image: $e");
                  //   return Center(child: Text("Failed to load image"));
                  // }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(product["gambar"]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product["nama_barang"] ?? "No Name",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Harga: Rp. " + product["harga"].toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          product["deskripsi"] ?? "No Description",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text("Failed to load data"));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      icon: Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: addToCart,
                  child: Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
